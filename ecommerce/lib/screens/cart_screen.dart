// lib/screens/cart_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ecommerce/services/cart_service.dart';
import 'package:ecommerce/screens/checkout_page.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // refresh cart on open
    CartService.instance.fetchCart().catchError(
      (_) => CartResult(
        success: false,
        statusCode: null,
        message: 'fetchCart error',
      ),
    );
  }

  /// Normalize any type of result returned by CartService methods to a common shape.
  /// Accepts bool, int, Map, or typed result (dynamic).
  Map<String, dynamic> _normalizeResult(dynamic res) {
    bool ok = false;
    String? message;
    int? statusCode;

    if (res == null) {
      ok = false;
    } else if (res is bool) {
      ok = res;
    } else if (res is int) {
      statusCode = res;
      ok = res >= 200 && res < 300;
    } else if (res is Map) {
      final map = res;
      if (map.containsKey('success')) {
        ok = map['success'] == true;
      }
      if (!ok && map.containsKey('ok')) {
        ok = map['ok'] == true;
      }
      if (!ok && map.containsKey('cart')) {
        ok = true;
      }
      if (map.containsKey('message')) {
        message = map['message']?.toString();
      }
      if (map.containsKey('statusCode')) {
        final s = map['statusCode'];
        if (s is int) {
          statusCode = s;
        } else {
          statusCode = int.tryParse(s?.toString() ?? '');
        }
      }
    } else {
      // typed object (CartResult or similar) - try dynamic access
      try {
        final dyn = res as dynamic;
        if (dyn.success != null) {
          ok = dyn.success == true;
        }
        if (!ok && dyn.ok != null) {
          ok = dyn.ok == true;
        }
        if (!ok && dyn.cart != null) {
          ok = true;
        }
        if (dyn.message != null) {
          message = dyn.message.toString();
        }
        if (dyn.statusCode != null) {
          final sc = dyn.statusCode;
          if (sc is int) {
            statusCode = sc;
          } else {
            statusCode = int.tryParse(sc.toString());
          }
        }
      } catch (_) {
        // unknown non-null object — optimistic fallback
        ok = true;
      }
    }

    return {'ok': ok, 'message': message, 'statusCode': statusCode};
  }

  Future<void> _removeItem(String productId) async {
    if (productId.trim().isEmpty) return;
    try {
      final dynamic res = await CartService.instance.remove(productId);
      final norm = _normalizeResult(res);
      if (norm['ok'] == true) {
        await CartService.instance.fetchCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(norm['message'] ?? 'Removed from cart')),
        );
      } else {
        final low = (norm['message'] ?? '').toString().toLowerCase();
        final sc = norm['statusCode'] as int?;
        if (sc == 401 ||
            low.contains('auth') ||
            low.contains('login') ||
            low.contains('unauthorized')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to manage cart')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(norm['message'] ?? 'Failed to remove item')),
          );
        }
      }
    } catch (e, st) {
      debugPrint('removeItem error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error removing item')));
    }
  }

  Future<void> _changeQty(String productId, int newQty) async {
    if (productId.trim().isEmpty || newQty <= 0) return;
    try {
      final dynamic res = await CartService.instance.updateQty(
        productId,
        newQty,
      );
      final norm = _normalizeResult(res);
      if (norm['ok'] == true) {
        await CartService.instance.fetchCart();
      } else {
        final low = (norm['message'] ?? '').toString().toLowerCase();
        final sc = norm['statusCode'] as int?;
        if (sc == 401 ||
            low.contains('auth') ||
            low.contains('login') ||
            low.contains('unauthorized')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to update cart')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(norm['message'] ?? 'Failed to update quantity'),
            ),
          );
        }
      }
    } catch (e, st) {
      debugPrint('updateQty error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error updating quantity')));
    }
  }

  void _startCheckout() {
    final snapshot = CartService.instance.currentItems;
    if (snapshot.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    double total = 0.0;
    final payload = <Map<String, dynamic>>[];
    for (final it in snapshot) {
      final price = it.priceInPaise != null
          ? it.priceInPaise! / 100.0
          : it.price;
      total += price * it.qty;
      payload.add({
        'productId': it.productId,
        'name': it.title,
        'price': price,
        'qty': it.qty,
      });
    }

    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart total is invalid. Please check product prices.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(items: payload, amount: total),
      ),
    );
  }

  Widget _imageOrPlaceholder(String? url, {double? width, double? height}) {
    if (url == null || url.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_outlined, size: 30, color: Colors.grey),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(
          Icons.image_not_supported,
          size: 30,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartService.instance.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          // compute total from priceInPaise
          double total = 0.0;
          for (final it in items) {
            final paise = it.priceInPaise ?? (it.price * 100).round();
            final qty = it.qty;
            final price = paise / 100.0;
            total += price * qty;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final img = it.image;
                    final title = it.title;
                    final qty = it.qty;
                    final paise = it.priceInPaise ?? (it.price * 100).round();
                    final price = paise / 100.0;
                    final productId = it.productId.isNotEmpty
                        ? it.productId
                        : it.id;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: _imageOrPlaceholder(
                                img,
                                width: 72,
                                height: 72,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '₹${price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (productId.isNotEmpty) {
                                            _changeQty(
                                              productId,
                                              max(1, qty - 1),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          '$qty',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (productId.isNotEmpty) {
                                            _changeQty(productId, qty + 1);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${(price * qty).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    if (productId.isNotEmpty) {
                                      _removeItem(productId);
                                    }
                                  },
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _startCheckout,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
