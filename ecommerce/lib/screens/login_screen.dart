// lib/screens/login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:ecommerce/screens/admin/admin_panel.dart';
import '../utils/api.dart';
import '../services/notifications_service.dart';

// <-- NEW: import CartService so we can init it with the JWT token after login
import '../services/cart_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  final String adminEmail = "admin123@gmail.com";
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  /// Safely try to parse the role from various possible shapes of server response.
  String _extractRoleFromBody(Map<String, dynamic> body) {
    debugPrint('ROLE_EXTRACT: starting with body: $body');

    // 1) common top-level role
    if (body['role'] != null) {
      final val = body['role'];
      debugPrint('ROLE_EXTRACT: found top-level body.role -> $val');
      return val is String ? val : val.toString();
    }

    // 2) common "user" object
    if (body['user'] is Map<String, dynamic>) {
      final user = Map<String, dynamic>.from(body['user']);
      debugPrint('ROLE_EXTRACT: found body.user -> $user');
      // direct role
      if (user['role'] != null) return user['role'].toString();
      if (user['roles'] != null) {
        final roles = user['roles'];
        if (roles is List && roles.isNotEmpty) return roles.first.toString();
        if (roles is String) return roles;
      }
      // other naming variants
      if (user['userRole'] != null) return user['userRole'].toString();
      if (user['roleName'] != null) return user['roleName'].toString();
    }

    // 3) maybe response wraps data: { data: { user: { role } } }
    if (body['data'] is Map<String, dynamic>) {
      final data = Map<String, dynamic>.from(body['data']);
      debugPrint('ROLE_EXTRACT: found body.data -> $data');
      // try nested
      if (data['role'] != null) return data['role'].toString();
      if (data['user'] is Map<String, dynamic>) {
        final user = Map<String, dynamic>.from(data['user']);
        if (user['role'] != null) return user['role'].toString();
        if (user['roles'] is List && (user['roles'] as List).isNotEmpty) return (user['roles'] as List).first.toString();
      }
    }

    // 4) maybe role is at body['payload'] or body['claims']
    if (body['payload'] is Map<String, dynamic> && body['payload']['role'] != null) {
      return body['payload']['role'].toString();
    }
    if (body['claims'] is Map<String, dynamic> && body['claims']['role'] != null) {
      return body['claims']['role'].toString();
    }

    debugPrint('ROLE_EXTRACT: role not found in body.');
    return '';
  }

  /// Quick and permissive JWT decode to extract payload (no signature validation).
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payloadBase64 = base64.normalize(parts[1].replaceAll('-', '+').replaceAll('_', '/'));
      final payloadString = utf8.decode(base64.decode(payloadBase64));
      final payload = json.decode(payloadString) as Map<String, dynamic>;
      debugPrint('JWT_PAYLOAD: $payload');
      return payload;
    } catch (e) {
      debugPrint('JWT decode failed: $e');
      return null;
    }
  }

  /// Authenticate with backend. Returns the full response body on success (contains token and user).
  Future<Map<String, dynamic>?> _authenticate(String email, String password) async {
    try {
      final result = await post('/auth/login', {'email': email, 'password': password});
      debugPrint('LOGIN: raw post result: $result');

      final status = result['status'] as int?;
      final body = result['body'] as Map<String, dynamic>?;

      debugPrint('LOGIN: status=$status, body=$body');

      if (status == 200 && body != null && (body['success'] == true || body['ok'] == true) && body['token'] != null) {
        final token = body['token'].toString();

        // Save token: try saveToken helper, fallback to secure storage
        try {
          await saveToken(token);
          debugPrint('LOGIN: saveToken() succeeded');
        } catch (e) {
          debugPrint('LOGIN: saveToken failed or not present: $e — writing token to secure storage');
          await _storage.write(key: 'token', value: token);
        }

        // Persist user object if exists
        if (body['user'] != null) {
          try {
            final userJson = jsonEncode(body['user']);
            await _storage.write(key: 'user', value: userJson);
            debugPrint('LOGIN: saved body.user to storage');
          } catch (e) {
            debugPrint('LOGIN: failed saving user json: $e');
          }
        }

        // Try to extract role from body
        String role = _extractRoleFromBody(body);

        // If still empty, try decode JWT for "role" or "roles" claim
        if (role.isEmpty) {
          final payload = _decodeJwtPayload(token);
          if (payload != null) {
            if (payload['role'] != null) role = payload['role'].toString();
            if (role.isEmpty && payload['roles'] is List && (payload['roles'] as List).isNotEmpty) {
              role = payload['roles'].first.toString();
            }
            // Some tokens use 'user' nested
            if (role.isEmpty && payload['user'] is Map<String, dynamic>) {
              final u = Map<String, dynamic>.from(payload['user']);
              if (u['role'] != null) role = u['role'].toString();
            }
          }
        }

        // If role discovered, save it
        if (role.isNotEmpty) {
          await _storage.write(key: 'role', value: role);
          debugPrint('LOGIN: role extracted and saved -> $role');
        } else {
          debugPrint('LOGIN: no role found in body or token payload');
        }

        // ------------------ NEW: configure & init CartService ------------------
        // Ensure CartService talks to the same API prefix your server exposes.
        // Your server uses '/api/v1/cart' so set prefix to '/api/v1'
        try {
          CartService.instance.configure(apiPrefix: '/api/v1', port: 443, host: 'backend001-88nd.onrender.com', useHttps: true);
          // Initialize with token so CartService will include Authorization header
          await CartService.instance.init(token: token);
          debugPrint('LOGIN: CartService initialized with token');
        } catch (e) {
          debugPrint('LOGIN: CartService init/config error: $e');
        }
        // ---------------------------------------------------------------------

        return body;
      } else {
        debugPrint('LOGIN: authentication failed or structure unexpected. body: $body');
        return null;
      }
    } catch (e, st) {
      debugPrint('Auth error: $e\n$st');
      return null;
    }
  }

  /// Decide role using multiple fallbacks and then navigate.
  Future<void> _decideAndNavigate(Map<String, dynamic>? response, String email) async {
    String role = '';

    // 1. try response body
    if (response != null) {
      try {
        final r = _extractRoleFromBody(response);
        if (r.isNotEmpty) role = r;
      } catch (e) {
        debugPrint('DECIDE: error extracting from response: $e');
      }
    }

    // 2. try secure storage
    if (role.isEmpty) {
      final stored = await _storage.read(key: 'role');
      debugPrint('DECIDE: role from storage -> $stored');
      if (stored != null && stored.isNotEmpty) role = stored;
    }

    // 3. email fallback
    if (role.isEmpty) {
      role = email.toLowerCase() == adminEmail.toLowerCase() ? 'admin' : 'user';
      debugPrint('DECIDE: fallback from email -> $role');
    }

    // Normalize and final logging
    final normalized = role.toLowerCase();
    debugPrint('DECIDE: final normalized role = $normalized');

    // Show feedback on-device (helps immediate debugging)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detected role: $normalized')));
    }

    // Navigate
    if (!mounted) return;
    if (normalized == 'admin' || normalized == 'superadmin' || normalized == 'administrator') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPanel()));
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final email = _emailCtrl.text.trim();
    final password = _pwdCtrl.text.trim();

    final response = await _authenticate(email, password);
    setState(() => _loading = false);

    if (response != null) {
      // Add a notification for successful login
      final now = DateTime.now();
      NotificationsService.instance.add(
        NotificationItem(
          id: now.millisecondsSinceEpoch.toString(),
          title: 'Logged in',
          body: 'You signed in at ${DateFormat.jm().format(now)}',
          time: now,
          isRead: false,
          icon: Icons.login,
        ),
      );

      await _decideAndNavigate(response, email);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed — check credentials')));
      }
    }
  }

  Widget socialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {double? width}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          'Log into\nyour account',
          style: TextStyle(fontSize: width != null && width > 500 ? 34 : 26, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  border: UnderlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter email';
                  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!re.hasMatch(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Password
              TextFormField(
                controller: _pwdCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter password' : null,
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password tapped')),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF372726),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('LOG IN', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),

              const Text('or log in with', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  socialIcon(Icons.apple, () {}),
                  const SizedBox(width: 14),
                  socialIcon(Icons.g_mobiledata, () {}),
                  const SizedBox(width: 14),
                  socialIcon(Icons.facebook, () {}),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (width != null) {
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: SizedBox(width: width, child: content));
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          if (w < 700) {
            return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 28, 24, 24), child: _buildForm(context));
          }
          final cardMaxWidth = w > 1100 ? 1000.0 : w * 0.9;
          return Center(
            child: Container(
              width: cardMaxWidth,
              height: 520,
              margin: const EdgeInsets.symmetric(vertical: 40),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                        gradient: LinearGradient(
                          colors: [Theme.of(context).colorScheme.primary.withOpacity(0.08), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(height: 40, child: Text('Your App', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor))),
                        const Spacer(),
                        Text("Welcome back!\nSign in to continue.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                        const SizedBox(height: 18),
                        Text("Manage your orders, wishlist and profile from a single place.", style: TextStyle(color: Colors.grey.shade600, height: 1.35)),
                        const Spacer(),
                      ]),
                    ),
                  ),
                  Expanded(flex: 6, child: Padding(padding: const EdgeInsets.all(28.0), child: SingleChildScrollView(child: _buildForm(context, width: 420)))),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}
