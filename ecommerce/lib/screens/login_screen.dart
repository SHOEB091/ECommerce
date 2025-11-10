// lib/screens/login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'admin/admin_panel.dart';
import 'admin/admin_panel.dart'; // ensure this file exists

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/api.dart';
import 'admin/admin_panel.dart';


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

  Future<bool> _authenticate(String email, String password) async {
    try {
      final result = await post('/auth/login', {'email': email, 'password': password});
      final status = result['status'] as int;
      final body = result['body'] as Map<String, dynamic>?;
      if (status == 200 && body != null && body['success'] == true && body['token'] != null) {
        await saveToken(body['token'] as String);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final email = _emailCtrl.text.trim();
    final password = _pwdCtrl.text.trim();

    final success = await _authenticate(email, password);
    setState(() => _loading = false);

    if (success) {
      final email = _emailCtrl.text.trim();

      // ✅ Admin redirect logic
      if (email.toLowerCase() == adminEmail.toLowerCase()) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPanel()));
        return;
      }

      // Normal user → Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed — check credentials')));
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
              const SizedBox(height: 6),
              const Text(
                'Log into\nyour account',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
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
                        onPressed: _loading ? null : _submit,
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
                        _socialIcon(Icons.apple, () {}),
                        const SizedBox(width: 14),
                        _socialIcon(Icons.g_mobiledata, () {}),
                        const SizedBox(width: 14),
                        _socialIcon(Icons.facebook, () {}),
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
              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  border: UnderlineInputBorder(),
                ),
                decoration: const InputDecoration(hintText: 'Email address', border: UnderlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter email';
                  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!re.hasMatch(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pwdCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter password' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot password tapped')));
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF372726), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('LOG IN', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('or log in with', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [socialIcon(Icons.apple, () {}), const SizedBox(width: 14), socialIcon(Icons.g_mobiledata, () {}), const SizedBox(width: 14), socialIcon(Icons.facebook, () {})]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Don't have an account?"),
                const SizedBox(width: 8),
                InkWell(onTap: () => Navigator.pushReplacementNamed(context, '/signup'), child: Text('Sign Up', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600))),
              ]),
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
                        gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.08), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
