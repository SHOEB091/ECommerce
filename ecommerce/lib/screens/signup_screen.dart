// lib/screens/sign_up_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/otp_verification_screen.dart';
import '../utils/api.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    try {
      // Use api helper or raw http
      final result = await post('/auth/email-send-otp', {'email': email});
      final status = result['status'] as int;
      final body = result['body'] as Map<String, dynamic>?;

      if (status == 200 && body != null && (body['success'] == true || body['message'] != null)) {
        // Navigate to OTP screen with signup data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: email,
              name: name,
              password: password,
              fromSignup: true,
            ),
          ),
        );
      } else {
        final msg = body != null ? (body['message'] ?? 'Failed to send OTP') : 'Failed to send OTP';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _socialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildForm({double? width}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          'Create\nyour account',
          style: TextStyle(
            fontSize: width != null && width > 500 ? 32 : 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: UnderlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  border: UnderlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  final emailRegex = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
                      r"[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Password
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Confirm password
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm password';
                  }
                  if (v != _passwordCtrl.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              // Sign up button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('SIGN UP', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('or sign up with', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(Icons.apple, () {}),
                  const SizedBox(width: 16),
                  _socialButton(Icons.g_mobiledata, () {}),
                  const SizedBox(width: 16),
                  _socialButton(Icons.facebook, () {}),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have account?'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: Text('Log in',
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                  )
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
            return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(28, 24, 28, 36), child: _buildForm());
          }
          final cardMaxWidth = w > 1100 ? 1000.0 : w * 0.88;
          return Center(
            child: Container(
              width: cardMaxWidth,
              height: 560,
              margin: const EdgeInsets.symmetric(vertical: 40),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                          gradient: LinearGradient(
                            colors: [Theme.of(context).colorScheme.primary.withOpacity(0.06), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(height: 40, child: Text('Your App', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor))),
                          const Spacer(),
                          Text('Join us\nand start shopping.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                          const SizedBox(height: 14),
                          Text('Create an account to save your favourites, track orders and enjoy exclusive offers.', style: TextStyle(color: Colors.grey.shade600, height: 1.35)),
                          const Spacer(),
                        ]),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(padding: const EdgeInsets.all(28.0), child: SingleChildScrollView(child: _buildForm(width: 460))),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
