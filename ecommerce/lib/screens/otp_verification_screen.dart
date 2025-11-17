// lib/screens/otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:intl/intl.dart';

import '../utils/api.dart';
import '../services/notifications_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final bool fromSignup;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.name = '',
    this.password = '',
    this.fromSignup = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otp = '';
  bool _loading = false;
  int _secondsLeft = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() {
          _canResend = true;
          _secondsLeft = 0;
        });
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    setState(() => _loading = true);
    try {
      final result = await post('/auth/email-send-otp', {'email': widget.email});
      final status = result['status'] as int;
      final body = result['body'] as Map<String, dynamic>?;
      if (status == 200 && body != null && (body['success'] == true || body['message'] != null)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent')));
        _startTimer();

        // Optionally add a notification that OTP was resent
        final now = DateTime.now();
        NotificationsService.instance.add(
          NotificationItem(
            id: now.millisecondsSinceEpoch.toString(),
            title: 'OTP resent',
            body: 'A new OTP was sent to ${widget.email} at ${DateFormat.jm().format(now)}',
            time: now,
            isRead: false,
            icon: Icons.email,
          ),
        );
      } else {
        final msg = body != null ? (body['message'] ?? 'Failed to resend OTP') : 'Failed to resend OTP';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the OTP sent to your email')));
      return;
    }
    setState(() => _loading = true);
    try {
      final payload = {'email': widget.email, 'otp': _otp};
      if (widget.fromSignup) {
        payload['name'] = widget.name;
        payload['password'] = widget.password;
      }
      final result = await post('/auth/email-verify-otp', payload);
      final status = result['status'] as int;
      final body = result['body'] as Map<String, dynamic>?;
      if (status == 200 && body != null && body['success'] == true && body['token'] != null) {
        final token = body['token'] as String;
        await saveToken(token);

        // If this flow was from signup, add a welcome notification
        final now = DateTime.now();
        if (widget.fromSignup) {
          NotificationsService.instance.add(
            NotificationItem(
              id: now.millisecondsSinceEpoch.toString(),
              title: 'Welcome to GemStore',
              body: 'Account created successfully. Happy shopping!',
              time: now,
              isRead: false,
              icon: Icons.thumb_up_alt_outlined,
            ),
          );
        } else {
          // If not from signup, still add a login notification (optional)
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
        }

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final msg = body != null ? (body['message'] ?? 'OTP verification failed') : 'OTP verification failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildOtpInput() {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      onChanged: (val) => _otp = val,
      onCompleted: (val) {
        _otp = val;
      },
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(6),
        fieldHeight: 48,
        fieldWidth: 40,
      ),
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text('Enter the 6-digit code sent to ${widget.email}', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 18),
              _buildOtpInput(),
              const SizedBox(height: 8),
              Text(_canResend ? 'You can resend code' : 'Resend in $_secondsLeft s', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verifyOtp,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify & Continue'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _canResend && !_loading ? _resendOtp : null, child: const Text('Resend OTP')),
            ],
          ),
        ),
      ),
    );
  }
}
