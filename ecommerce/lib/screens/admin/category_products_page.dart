// lib/screens/admin/category_products_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:ecommerce/services/cart_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ecommerce/screens/admin/product_model.dart';
import 'package:ecommerce/screens/admin/category_model.dart';

class CategoryProductsPage extends StatefulWidget {
  final Category category;
  const CategoryProductsPage({super.key, required this.category});

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Product> _all = [];
  List<Product> _filtered = [];
  bool _loading = true;
  String? _error;

  String _base(int port) {
    if (kIsWeb) return 'http://localhost:$port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
    return 'http://localhost:$port/api';
  }

  @override
  void initState() {
    super.initState();
    _loadAndFilter();
  }

  Future<void> _loadAndFilter() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = '${_base(5000)}/products';
      final res = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = json.decode(res.body);
        final raw = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
        final list = <Product>[];
        if (raw is List) {
          for (final e in raw) {
            try {
              list.add(Product.fromJson(Map<String, dynamic>.from(e)));
            } catch (ex) {
              debugPrint('parse product error: $ex');
            }
          }
        }
        _all = list;
        _applyFilter();
      } else {
        setState(() {
          _error = 'Failed to load products (${res.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final catId = (widget.category.id ?? '').toString().trim();
    final catName = (widget.category.name ?? '').toString().trim().toLowerCase();

    final filtered = _all.where((p) {
      final prodCatRaw = p.category ?? '';
      final prodCat = prodCatRaw.toString();
      if (prodCat.isEmpty) return false;

      // Try matching by id or by name string
      if (catId.isNotEmpty && prodCat == catId) return true;
      if (catName.isNotEmpty && prodCat.toLowerCase() == catName) return true;
      if (catId.isNotEmpty && prodCat.contains(catId)) return true;
      if (catName.isNotEmpty && prodCat.toLowerCase().contains(catName)) return true;
      return false;
    }).toList();

    setState(() {
      _filtered = filtered;
      _loading = false;
    });
  }

  /// Interpret any return value from CartService.addItem(...) as success/failure.
  bool _interpretCartResult(dynamic res) {
    try {
      if (res == null) return false;
      if (res is bool) return res;
      // Common Map pattern: { success: true, message: '...' }
      if (res is Map) {
        if (res.containsKey('success')) return res['success'] == true;
        if (res.containsKey('ok')) return res['ok'] == true;
        if (res.containsKey('status') && (res['status'] == 200 || res['status'] == 'ok')) return true;
        if (res.containsKey('cart')) return true;
      }
      // If it's a typed object (CartResult etc.), try reading common properties
      final dyn = res as dynamic;
      if (dyn is! bool) {
        // try a few common property names
        try {
          final s = dyn.success;
          if (s is bool) return s;
        } catch (_) {}
        try {
          final s = dyn.ok;
          if (s is bool) return s;
        } catch (_) {}
        try {
          final cart = dyn.cart;
          if (cart != null) return true;
        } catch (_) {}
        try {
          final status = dyn.status;
          if (status == 200 || status == 'ok') return true;
        } catch (_) {}
      }
      // fallback: consider non-null result as success (optimistic)
      return true;
    } catch (e) {
      debugPrint('interpretCartResult error: $e');
      return false;
    }
  }

  /// Try to extract a user-friendly message from the addItem result.
  String? _messageFromCartResult(dynamic res) {
    try {
      if (res == null) return null;
      if (res is String) return res;
      if (res is Map) {
        if (res['message'] != null) return res['message'].toString();
        if (res['msg'] != null) return res['msg'].toString();
      }
      final dyn = res as dynamic;
      try {
        final m = dyn.message;
        if (m != null) return m.toString();
      } catch (_) {}
      try {
        final m = dyn.msg;
        if (m != null) return m.toString();
      } catch (_) {}
      // otherwise null
      return null;
    } catch (e) {
      debugPrint('messageFromCartResult error: $e');
      return null;
    }
  }

  Future<void> _addToCart(Product p) async {
    try {
      final res = await CartService.instance.addItem(p.id, qty: 1);
      final ok = _interpretCartResult(res);
      final msg = _messageFromCartResult(res);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg ?? (ok ? 'Added to cart' : 'Failed to add to cart'))));
    } catch (e) {
      debugPrint('addToCart error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
    }
  }

  void _openDetail(Product p) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)));
  }

  String _formatPrice(dynamic rawPrice) {
    if (rawPrice == null) return '0.00';
    if (rawPrice is num) return (rawPrice.toDouble()).toStringAsFixed(2);
    final asNum = double.tryParse(rawPrice.toString());
    return (asNum ?? 0.0).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1200 ? 4 : width >= 800 ? 3 : width >= 480 ? 2 : 1;

    return Scaffold(
      appBar: AppBar(title: Text((widget.category.name ?? 'Category').toString())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _filtered.isEmpty
                  ? const Center(child: Text('No products in this category'))
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.builder(
                        itemCount: _filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemBuilder: (ctx, i) {
                          final p = _filtered[i];
                          final imageUrl = (p.imageUrl ?? '').toString().trim();
                          final priceStr = _formatPrice(p.price);
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _openDetail(p),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]))
                                        : Container(color: Colors.grey[200]),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(p.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text('₹$priceStr', style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    ElevatedButton.icon(onPressed: () => _addToCart(p), icon: const Icon(Icons.add_shopping_cart_outlined), label: const Text('Add')),
                                    const SizedBox(width: 8),
                                    OutlinedButton(onPressed: () => _openDetail(p), child: const Text('Details')),
                                  ]),
                                ]),
                              ),
                            ]),
                          );
                        },
                      ),
                    ),
    );
  }
}

/// Lightweight local product detail page so category -> detail always compiles.
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  Widget _imageFallback({double? height}) {
    return Container(height: height, color: Colors.grey[100], child: const Center(child: Icon(Icons.image_not_supported, size: 44, color: Colors.grey)));
  }

  String _formatPrice(dynamic rawPrice) {
    if (rawPrice == null) return '0.00';
    if (rawPrice is num) return (rawPrice.toDouble()).toStringAsFixed(2);
    final asNum = double.tryParse(rawPrice.toString());
    return (asNum ?? 0.0).toStringAsFixed(2);
  }

  bool _interpretCartResult(dynamic res) {
    // reuse same logic as above — slightly redundant but keeps this widget self-contained.
    try {
      if (res == null) return false;
      if (res is bool) return res;
      if (res is Map) {
        if (res.containsKey('success')) return res['success'] == true;
        if (res.containsKey('ok')) return res['ok'] == true;
        if (res.containsKey('status') && (res['status'] == 200 || res['status'] == 'ok')) return true;
        if (res.containsKey('cart')) return true;
      }
      final dyn = res as dynamic;
      try {
        final s = dyn.success;
        if (s is bool) return s;
      } catch (_) {}
      try {
        final s = dyn.ok;
        if (s is bool) return s;
      } catch (_) {}
      try {
        final cart = dyn.cart;
        if (cart != null) return true;
      } catch (_) {}
      return true;
    } catch (e) {
      debugPrint('interpretCartResult error: $e');
      return false;
    }
  }

  String? _messageFromCartResult(dynamic res) {
    try {
      if (res == null) return null;
      if (res is String) return res;
      if (res is Map) {
        if (res['message'] != null) return res['message'].toString();
        if (res['msg'] != null) return res['msg'].toString();
      }
      final dyn = res as dynamic;
      try {
        final m = dyn.message;
        if (m != null) return m.toString();
      } catch (_) {}
      try {
        final m = dyn.msg;
        if (m != null) return m.toString();
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('messageFromCartResult error: $e');
      return null;
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    try {
      final res = await CartService.instance.addItem(product.id, qty: 1);
      final ok = _interpretCartResult(res);
      final msg = _messageFromCartResult(res);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg ?? (ok ? 'Added to cart' : 'Failed to add to cart'))));
    } catch (e) {
      debugPrint('addToCart error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = product.name ?? 'Product';
    final priceStr = _formatPrice(product.price);
    final img = (product.imageUrl ?? '').toString().trim();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (isDesktop) {
      final double leftWidth = (screenWidth * 0.42).clamp(320.0, 520.0);
      final double imgHeight = leftWidth * 0.95;
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
                          onPressed: () => _addToCart(context),
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
                )),
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
            Expanded(child: ElevatedButton.icon(onPressed: () => _addToCart(context), icon: const Icon(Icons.add_shopping_cart), label: const Text('Add to cart'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), child: Text('Close'))),
          ]),
        ]),
      ),
    );
  }
}
