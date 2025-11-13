// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:ecommerce/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _formatCurrency(int paise) {
    final rupees = paise / 100.0;
    return '₹${rupees.toStringAsFixed(2)}';
  }

  @override
  void initState() {
    super.initState();
    // Make sure cart has been loaded
    CartService.instance.fetchCart();
  }

  /// Interpret many possible shapes of results returned by CartService methods.
  bool _interpretSuccess(dynamic res) {
    try {
      if (res == null) return false;
      if (res is bool) return res;
      if (res is int) return res == 200;
      if (res is Map) {
        if (res.containsKey('success')) return res['success'] == true;
        if (res.containsKey('ok')) return res['ok'] == true;
        if (res.containsKey('cart')) return true;
      }
      // typed object fallback
      try {
        final dyn = res as dynamic;
        final s = dyn.success;
        if (s is bool) return s == true;
      } catch (_) {}
      try {
        final dyn = res as dynamic;
        if (dyn.cart != null) return true;
      } catch (_) {}
      // optimistic fallback if non-null
      return true;
    } catch (e) {
      debugPrint('_interpretSuccess error: $e');
      return false;
    }
  }

  String? _extractMessage(dynamic res) {
    try {
      if (res == null) return null;
      if (res is String) return res;
      if (res is Map) {
        if (res['message'] != null) return res['message'].toString();
        if (res['msg'] != null) return res['msg'].toString();
      }
      try {
        final dyn = res as dynamic;
        if (dyn.message != null) return dyn.message.toString();
      } catch (_) {}
      try {
        final dyn = res as dynamic;
        if (dyn.msg != null) return dyn.msg.toString();
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('_extractMessage error: $e');
      return null;
    }
  }

  Future<void> _changeQty(String productId, int qty) async {
    try {
      final res = await CartService.instance.updateQty(productId, qty);
      final ok = _interpretSuccess(res);
      final msg = _extractMessage(res);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg ?? 'Failed to update quantity')));
      } else {
        // refresh local cart (CartService may already update items, but ensure UI is fresh)
        await CartService.instance.fetchCart();
        if (msg != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e, st) {
      debugPrint('updateQty error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error updating quantity')));
    }
  }

  Future<void> _removeItem(String productId) async {
    try {
      final res = await CartService.instance.remove(productId);
      final ok = _interpretSuccess(res);
      final msg = _extractMessage(res);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg ?? 'Failed to remove item')));
      } else {
        await CartService.instance.fetchCart();
        if (msg != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e, st) {
      debugPrint('removeItem error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error removing item')));
    }
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
      body: SafeArea(
        child: ValueListenableBuilder<List<CartItem>>(
          valueListenable: CartService.instance.items,
          builder: (context, items, _) {
            if (items.isEmpty) {
              return const Center(child: Text('Your cart is empty'));
            }

            // compute totalPaise defensively
            int totalPaise = 0;
            for (final it in items) {
              final qty = (it.qty >= 0) ? it.qty : 1;
              final price = (it.priceInPaise >= 0) ? it.priceInPaise : 0;
              totalPaise += (qty * price);
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final it = items[i];
                      final title = it.title;
                      final image = it.image;
                      final qty = (it.qty >= 0) ? it.qty : 1;
                      final pricePaise = (it.priceInPaise >= 0) ? it.priceInPaise : 0;
                      final lineTotalPaise = pricePaise * qty;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                                clipBehavior: Clip.hardEdge,
                                child: image != null && image.isNotEmpty
                                    ? Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.image_not_supported, color: Colors.grey.shade600)))
                                    : Center(child: Icon(Icons.image_not_supported, color: Colors.grey.shade600)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    Text(_formatCurrency(pricePaise), style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          final newQty = (qty - 1).clamp(0, 9999);
                                          _changeQty(it.id, newQty);
                                        },
                                        icon: const Icon(Icons.remove_circle_outline),
                                      ),
                                      Text('$qty', style: const TextStyle(fontWeight: FontWeight.w700)),
                                      IconButton(
                                        onPressed: () {
                                          final newQty = (qty + 1).clamp(0, 9999);
                                          _changeQty(it.id, newQty);
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(_formatCurrency(lineTotalPaise), style: const TextStyle(fontWeight: FontWeight.w700)),
                                  TextButton(
                                    onPressed: () => _removeItem(it.id),
                                    child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
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
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Total', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(_formatCurrency(totalPaise), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout tapped')));
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                        child: const Text('Checkout'),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
