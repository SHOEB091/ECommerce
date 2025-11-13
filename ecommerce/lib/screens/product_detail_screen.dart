// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:ecommerce/services/cart_service.dart';
import 'package:ecommerce/screens/admin/product_model.dart';

/// Product detail page that safely adds item to cart.
/// Expects a Product instance with a valid `id` field.
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  String _formatPrice(dynamic raw) {
    if (raw == null) return '0.00';
    if (raw is num) return raw.toDouble().toStringAsFixed(2);
    final parsed = double.tryParse(raw.toString());
    return (parsed ?? 0.0).toStringAsFixed(2);
  }

  /// Interpret many shapes of results from CartService (bool, Map, typed object)
  bool _interpretSuccess(dynamic res) {
    try {
      if (res == null) return false;
      if (res is bool) return res;
      if (res is int) return res == 200 || res == 201;
      if (res is Map) {
        if (res.containsKey('success')) return res['success'] == true;
        if (res.containsKey('ok')) return res['ok'] == true;
        if (res.containsKey('cart')) return true;
      }
      // typed object fallback via dynamic
      try {
        final dyn = res as dynamic;
        if (dyn.success != null && dyn.success is bool) return dyn.success == true;
      } catch (_) {}
      try {
        final dyn = res as dynamic;
        if (dyn.cart != null) return true;
      } catch (_) {}
      // optimistic fallback for non-null unknown shape
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

  Future<void> _handleAddToCart(BuildContext ctx) async {
    try {
      final pid = (product.id ?? '').toString().trim();
      debugPrint('ProductDetail: addToCart pressed for productId="$pid"');

      if (pid.isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Product id missing — cannot add to cart')));
        return;
      }

      // Call CartService and handle various return types
      final res = await CartService.instance.addItem(pid, qty: 1);
      debugPrint('ProductDetail: CartService.addItem returned -> $res');

      final ok = _interpretSuccess(res);
      final msg = _extractMessage(res);

      // If success, ensure cart is refreshed so badge updates
      if (ok) {
        // some implementations update items internally; call fetchCart to be safe
        try {
          await CartService.instance.fetchCart();
        } catch (e) {
          debugPrint('ProductDetail: fetchCart after addItem failed: $e');
        }
      }

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg ?? (ok ? 'Added to cart' : 'Failed to add to cart'))));
    } catch (e, st) {
      debugPrint('ProductDetail: addToCart error: $e\n$st');
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Error adding to cart')));
    }
  }

  Widget _imageFallback({double? height}) {
    return Container(height: height, color: Colors.grey[100], child: const Center(child: Icon(Icons.image_not_supported, size: 44, color: Colors.grey)));
  }

  @override
  Widget build(BuildContext context) {
    final title = product.name ?? 'Product';
    final priceStr = _formatPrice(product.price);
    final img = (product.imageUrl ?? '').toString().trim();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (isDesktop) {
      final leftWidth = (screenWidth * 0.42).clamp(320.0, 520.0);
      final imgHeight = leftWidth * 0.95;
      return Scaffold(
        appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black87)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black87)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: leftWidth,
                  child: Column(children: [
                    Container(
                      height: imgHeight,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
                      clipBehavior: Clip.hardEdge,
                      child: img.isNotEmpty ? Image.network(img, fit: BoxFit.contain, width: leftWidth, height: imgHeight, errorBuilder: (_, __, ___) => _imageFallback(height: imgHeight)) : _imageFallback(height: imgHeight),
                    ),
                    const SizedBox(height: 12),
                  ]),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text('₹$priceStr', style: const TextStyle(fontSize: 20, color: Colors.grey)),
                      const SizedBox(height: 14),
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(product.description ?? 'No description provided', style: const TextStyle(color: Colors.black87, height: 1.45)),
                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAddToCart(context),
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to cart'),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)), child: const Text('Close')),
                      ]),
                      const SizedBox(height: 12),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = (screenHeight * 0.45).clamp(260.0, 520.0);

    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black87)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black87)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
            clipBehavior: Clip.hardEdge,
            child: img.isNotEmpty ? Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback(height: imageHeight)) : _imageFallback(height: imageHeight),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('₹$priceStr', style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 14),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(product.description ?? 'No description provided', style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleAddToCart(context),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to cart'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), child: Text('Close'))),
          ]),
        ]),
      ),
    );
  }
}
