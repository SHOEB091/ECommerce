import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'admin/admin_panel.dart';
>>>>>>> 69bddba (admin panel and setting page)

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

<<<<<<< HEAD
=======

  final String adminEmail = "admin123@gmail.com";

>>>>>>> 69bddba (admin panel and setting page)
  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // Replace this with real authentication logic (Firebase, API, etc.)
  Future<bool> _fakeAuthenticate(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // demo: any non-empty credentials succeed
=======
  Future<bool> _fakeAuthenticate(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
>>>>>>> 69bddba (admin panel and setting page)
    return email.isNotEmpty && password.isNotEmpty;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final success = await _fakeAuthenticate(_emailCtrl.text.trim(), _pwdCtrl.text);
    setState(() => _loading = false);

    if (success) {
<<<<<<< HEAD
      // Navigate to Home screen and remove Login from the stack
=======
      final email = _emailCtrl.text.trim();

      // ✅ Admin redirect logic
      if (email.toLowerCase() == adminEmail.toLowerCase()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPanel()),
        );
        return;
      }

      // Normal user → Home
>>>>>>> 69bddba (admin panel and setting page)
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed — check credentials')),
      );
    }
  }

  Widget _socialIcon(IconData icon, VoidCallback onTap) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

<<<<<<< HEAD
                    // Forgot password (optional)
=======
>>>>>>> 69bddba (admin panel and setting page)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
<<<<<<< HEAD
                          // TODO: implement forgot password flow
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot password tapped')));
=======
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Forgot password tapped')),
                          );
>>>>>>> 69bddba (admin panel and setting page)
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),

<<<<<<< HEAD
                    // Login button
=======
>>>>>>> 69bddba (admin panel and setting page)
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

<<<<<<< HEAD
                    // Social sign-in row
=======
>>>>>>> 69bddba (admin panel and setting page)
                    const Text('or log in with', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
<<<<<<< HEAD
                        _socialIcon(Icons.apple, () {
                          // TODO: Apple sign in
                        }),
                        const SizedBox(width: 14),
                        _socialIcon(Icons.g_mobiledata, () {
                          // TODO: Google sign in
                        }),
                        const SizedBox(width: 14),
                        _socialIcon(Icons.facebook, () {
                          // TODO: Facebook sign in
                        }),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Link to Sign Up
=======
                        _socialIcon(Icons.apple, () {}),
                        const SizedBox(width: 14),
                        _socialIcon(Icons.g_mobiledata, () {}),
                        const SizedBox(width: 14),
                        _socialIcon(Icons.facebook, () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
>>>>>>> 69bddba (admin panel and setting page)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
<<<<<<< HEAD
                          child: Text('Sign Up', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
=======
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
>>>>>>> 69bddba (admin panel and setting page)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
