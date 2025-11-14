// lib/screens/admin/category_products_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ecommerce/services/cart_service.dart';
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
    return 'https://backend001-88nd.onrender.com/api';
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
      final res = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = json.decode(res.body);
        final raw = (decoded is Map && decoded.containsKey('data'))
            ? decoded['data']
            : decoded;
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
    final catId = widget.category.id.trim();
    final catName = widget.category.name.trim().toLowerCase();

    final filtered = _all.where((p) {
      final prodCat = p.category.toString();
      if (prodCat.isEmpty) {
        return false;
      }

      if (catId.isNotEmpty && prodCat == catId) {
        return true;
      }
      if (catName.isNotEmpty && prodCat.toLowerCase() == catName) {
        return true;
      }
      if (catId.isNotEmpty && prodCat.contains(catId)) {
        return true;
      }
      if (catName.isNotEmpty && prodCat.toLowerCase().contains(catName)) {
        return true;
      }
      return false;
    }).toList();

    setState(() {
      _filtered = filtered;
      _loading = false;
    });
  }

  Future<void> _addToCart(Product p) async {
    final id = p.id.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product id missing — cannot add to cart'),
        ),
      );
      return;
    }

    try {
      final CartResult? res = await CartService.instance.addItem(id, qty: 1);
      debugPrint('CategoryProductsPage add returned: $res');
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add to cart (no response)')),
        );
        return;
      }

      final String message = res.message?.trim() ?? '';
      final String lower = message.toLowerCase();

      if (res.success) {
        try {
          await CartService.instance.fetchCart();
        } catch (_) {}
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty ? message : 'Added to cart'),
          ),
        );
      } else {
        if (res.statusCode == 401 ||
            lower.contains('auth') ||
            lower.contains('login') ||
            lower.contains('unauthorized')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to add items to cart')),
          );
        } else if (res.statusCode == 404 ||
            lower.contains('route not found') ||
            lower.contains('not found')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.isNotEmpty ? message : 'Product not found'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message.isNotEmpty ? message : 'Failed to add to cart',
              ),
            ),
          );
        }
      }
    } catch (e, st) {
      debugPrint('Error adding to cart: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error adding to cart')));
    }
  }

  void _openDetail(Product p) {
    // Navigate to the map-based ProductDetails used by HomeScreen (if present).
    // If you have a different ProductDetail widget (e.g. ProductDetailScreen), swap below.
    final map = <String, String>{
      'id': p.id,
      'img': p.imageUrl,
      'title': p.name,
      'price': p.price.toStringAsFixed(2),
      'description': p.description,
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailsFromMap(product: map)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1200
        ? 4
        : width >= 800
        ? 3
        : width >= 480
        ? 2
        : 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            )
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
                  final imageUrl = p.imageUrl.trim();
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _openDetail(p),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: Colors.grey[200]),
                                    )
                                  : Container(color: Colors.grey[200]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _addToCart(p),
                                    icon: const Icon(
                                      Icons.add_shopping_cart_outlined,
                                    ),
                                    label: const Text('Add'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () => _openDetail(p),
                                    child: const Text('Details'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

/// Minimal ProductDetails wrapper that expects a map of product strings.
/// If you already have a ProductDetails widget (map-based) in home_screen.dart,
/// either import and use that or keep this simple passthrough.
class ProductDetailsFromMap extends StatelessWidget {
  final Map<String, String> product;
  const ProductDetailsFromMap({super.key, required this.product});

  Widget _imageFallback({double? height}) {
    return Container(
      height: height,
      color: Colors.grey[100],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 44, color: Colors.grey),
      ),
    );
  }

  Future<void> _addFromDetails(BuildContext ctx) async {
    final id = (product['id'] ?? '').trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Product id missing — cannot add to cart'),
        ),
      );
      return;
    }
    try {
      final CartResult? res = await CartService.instance.addItem(id, qty: 1);
      if (res == null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Failed to add to cart (no response)')),
        );
        return;
      }
      final String message = res.message?.trim() ?? '';
      final String lower = message.toLowerCase();
      if (res.success) {
        await CartService.instance.fetchCart();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty ? message : 'Added to cart'),
          ),
        );
      } else {
        if (res.statusCode == 401 ||
            lower.contains('auth') ||
            lower.contains('unauthorized')) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Please login to add items to cart')),
          );
        } else {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                message.isNotEmpty ? message : 'Failed to add to cart',
              ),
            ),
          );
        }
      }
    } catch (e, st) {
      debugPrint('Error adding from details: $e\n$st');
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Error adding to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = product['title'] ?? 'Product';
    final price = product['price'] ?? '';
    final img = product['img'];
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = (screenHeight * 0.45).clamp(260.0, 520.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              clipBehavior: Clip.hardEdge,
              child: img != null && img.isNotEmpty
                  ? Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imageFallback(height: imageHeight),
                    )
                  : _imageFallback(height: imageHeight),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '₹$price',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              product['description'] ?? 'No description provided',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addFromDetails(context),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
