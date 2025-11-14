// lib/screens/checkout_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ecommerce/services/cart_service.dart';
import 'package:ecommerce/services/order_service.dart';
import '../utils/api.dart'; // post(), saveToken()
import 'dart:io' show Platform;

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items; // [{productId, name, price, qty}]
  final double amount; // in rupees
  const CheckoutPage({super.key, required this.items, required this.amount});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Razorpay? _razorpay;
  bool _loading = false;
  Map? _localOrder; // local DB order returned by server
  Map? _razorpayOrder;
  String? _razorpayKey;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  bool get _isDesktop {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (e) {
      // Platform not available (e.g., on web)
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (!_isDesktop) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  @override
  void dispose() {
    if (!_isDesktop) {
      _razorpay?.clear();
    }
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() => _loading = true);
    try {
      final payload = {
        'items': widget.items,
        'amount': widget.amount,
        'currency': 'INR',
        'address': {
          'fullName': _nameCtrl.text.trim(),
          'line1': _line1Ctrl.text.trim(),
          'line2': _line2Ctrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'state': _stateCtrl.text.trim(),
          'postalCode': _postalCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
        },
      };
      final result = await post('/payments/order', payload, auth: true);
      final status = result['status'] as int;
      final body = result['body'] as Map<String, dynamic>?;

      if (status == 200 && body != null && body['success'] == true) {
        _localOrder = body['order'] is Map<String, dynamic>
            ? body['order'] as Map<String, dynamic>
            : body['order'] is Map
            ? Map<String, dynamic>.from(body['order'] as Map)
            : null;
        _razorpayOrder = body['razorpayOrder'] is Map<String, dynamic>
            ? body['razorpayOrder'] as Map<String, dynamic>
            : body['razorpayOrder'] is Map
            ? Map<String, dynamic>.from(body['razorpayOrder'] as Map)
            : body['razorpayorder'] is Map<String, dynamic>
            ? body['razorpayorder'] as Map<String, dynamic>
            : body['razorpayorder'] is Map
            ? Map<String, dynamic>.from(body['razorpayorder'] as Map)
            : null;
        _razorpayKey = body['key']?.toString();
        if (_razorpayOrder == null ||
            _razorpayOrder!.isEmpty ||
            _localOrder == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid server response')),
          );
          setState(() => _loading = false);
          return;
        }
        _openCheckout(_razorpayOrder!);
      } else {
        final msg = body != null
            ? (body['message'] ?? 'Failed to create order')
            : 'Failed to create order';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openCheckout(Map rOrder) {
    if (_isDesktop) {
      // For desktop, show dialog with payment instructions
      final orderId = rOrder['id']?.toString() ?? '';
      final amount = rOrder['amount']?.toString() ?? '';

      // Show dialog with payment instructions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Desktop Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Razorpay payment gateway is not available on desktop.',
              ),
              const SizedBox(height: 16),
              const Text('Please use one of the following options:'),
              const SizedBox(height: 8),
              Text('Order ID: $orderId'),
              Text('Amount: ₹${(int.tryParse(amount) ?? 0) / 100}'),
              const SizedBox(height: 16),
              const Text(
                'Option 1: Complete payment on mobile app\n'
                'Option 2: Contact support for manual payment\n'
                'Option 3: Use web version in browser',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final options = {
      'key':
          _razorpayKey ??
          const String.fromEnvironment(
            "RZP_KEY_ID",
            defaultValue: "<YOUR_RZP_TEST_KEY>",
          ),
      'amount': rOrder['amount'], // paise
      'order_id': rOrder['id'],
      'name': 'Your App',
      'description': 'Order payment',
      'prefill': {'email': '', 'contact': ''},
      'notes': {'localOrderId': _localOrder?['_id'] ?? ''},
      'theme': {'color': '#F37254'},
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error opening razorpay: $e');
    }
  }

  // robust verify with retries
  Future<bool> _verifyWithRetries(
    Map verifyPayload, {
    int retries = 3,
    int delayMs = 1000,
  }) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final result = await post(
          '/payments/verify',
          verifyPayload,
          auth: true,
        );
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
    final localOrderId = _localOrder?['_id'] ?? _localOrder?['id'];
    if (localOrderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Local order id missing')));
      return;
    }

    final verifyPayload = {
      'orderId': localOrderId,
      'razorpay_order_id': response.orderId,
      'razorpay_payment_id': response.paymentId,
      'razorpay_signature': response.signature,
    };

    // Try verifying with retries (network resilient)
    final ok = await _verifyWithRetries(
      verifyPayload,
      retries: 4,
      delayMs: 1500,
    );

    if (ok) {
      try {
        await CartService.instance.fetchCart();
      } catch (_) {}
      try {
        await OrderService.instance.fetchOrders();
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment verified!')));
      Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
    } else {
      // Save local retry instruction (you can use local DB or call a backend "mark-needs-verification" endpoint)
      // For now just inform user and provide manual retry button or check orders page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment succeeded but verification failed. We will reconcile soon.',
          ),
        ),
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
    // optional: hit /payments/mark-failed to update order status
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalLabel = 'Pay ₹${widget.amount.toStringAsFixed(2)}';

    // Show desktop warning banner
    if (_isDesktop) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Payment gateway is not available on desktop. Please use mobile app or web browser.',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shipping details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please enter recipient name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().length < 8
                              ? 'Enter a valid phone number'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _line1Ctrl,
                          decoration: const InputDecoration(
                            labelText: 'Address line 1',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Address line 1 is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _line2Ctrl,
                          decoration: const InputDecoration(
                            labelText: 'Address line 2 (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'City',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'City is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _stateCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'State',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _postalCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Postal code',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Postal code is required'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Order total: $totalLabel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _startPayment,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.lock_open),
                            label: Text(
                              _loading ? 'Processing...' : totalLabel,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shipping details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter recipient name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().length < 8
                      ? 'Enter a valid phone number'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _line1Ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Address line 1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Address line 1 is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _line2Ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Address line 2 (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'City is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _postalCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Postal code',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Postal code is required'
                      : null,
                ),
                const SizedBox(height: 24),
                Text(
                  'Order total: $totalLabel',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _startPayment,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_open),
                    label: Text(_loading ? 'Processing...' : totalLabel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
