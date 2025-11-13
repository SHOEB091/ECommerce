// lib/screens/checkout_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../utils/api.dart'; // post(), saveToken()
import 'package:connectivity_plus/connectivity_plus.dart'; // optional - add dependency if you use it

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items; // [{productId, name, price, qty}]
  final double amount; // in rupees
  const CheckoutPage({Key? key, required this.items, required this.amount}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Razorpay _razorpay;
  bool _loading = false;
  Map? _localOrder; // local DB order returned by server
  Map? _razorpayOrder;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _startPayment() async {
    setState(() => _loading = true);
    try {
      final payload = {
        'items': widget.items,
        'amount': widget.amount,
        'currency': 'INR',
      };
      final result = await post('/payments/create-order', payload, auth: true);
      final status = result['status'] as int;
      final body = result['body'] as Map<String, dynamic>?;

      if (status == 200 && body != null && body['success'] == true) {
        _localOrder = body['order'] as Map<String,dynamic>?;
        _razorpayOrder = body['razorpayOrder'] as Map<String,dynamic>? ?? body['razorpayorder'];
        if (_razorpayOrder == null || _localOrder == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid server response')));
          setState(() => _loading = false);
          return;
        }
        _openCheckout(_razorpayOrder!);
      } else {
        final msg = body != null ? (body['message'] ?? 'Failed to create order') : 'Failed to create order';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openCheckout(Map rOrder) {
    final options = {
      'key': '${const String.fromEnvironment("RZP_KEY_ID", defaultValue: "<YOUR_RZP_TEST_KEY>")}',
      'amount': rOrder['amount'], // paise
      'order_id': rOrder['id'],
      'name': 'Your App',
      'description': 'Order payment',
      'prefill': {'email': '', 'contact': ''},
      'notes': {'localOrderId': _localOrder?['_id'] ?? ''},
      'theme': {'color': '#F37254'}
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening razorpay: $e');
    }
  }

  // robust verify with retries
  Future<bool> _verifyWithRetries(Map verifyPayload, {int retries = 3, int delayMs = 1000}) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final result = await post('/payments/verify', verifyPayload, auth: true);
        final status = result['status'] as int;
        final body = result['body'] as Map<String, dynamic>?;
        if (status == 200 && body != null && body['success'] == true) {
          return true;
        } else {
          // server responded with failure (e.g., invalid signature) — do not retry
          debugPrint('verify failed server response: $body');
          return false;
        }
      } catch (e) {
        // network error - retry
        debugPrint('verify attempt $attempt failed: $e');
        if (attempt < retries) {
          await Future.delayed(Duration(milliseconds: delayMs * (attempt + 1)));
          continue;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Build verify payload with local order id
    final localOrderId = _localOrder?['_id'];
    if (localOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local order id missing')));
      return;
    }

    final verifyPayload = {
      'orderId': localOrderId,
      'razorpay_order_id': response.orderId,
      'razorpay_payment_id': response.paymentId,
      'razorpay_signature': response.signature,
    };

    // Try verifying with retries (network resilient)
    final ok = await _verifyWithRetries(verifyPayload, retries: 4, delayMs: 1500);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment verified!')));
      Navigator.pushReplacementNamed(context, '/order-success');
    } else {
      // Save local retry instruction (you can use local DB or call a backend "mark-needs-verification" endpoint)
      // For now just inform user and provide manual retry button or check orders page
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment succeeded but verification failed. We will reconcile soon.')));
      Navigator.pushReplacementNamed(context, '/order-pending'); // implement order pending screen
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: ${response.message}')));
    // optional: hit /payments/mark-failed to update order status
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('External wallet: ${response.walletName}')));
  }

  @override
  Widget build(BuildContext context) {
    final label = 'Pay ₹${widget.amount.toStringAsFixed(2)}';
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: ElevatedButton(
          onPressed: _loading ? null : _startPayment,
          child: _loading ? const CircularProgressIndicator() : Text(label),
        ),
      ),
    );
  }
}
