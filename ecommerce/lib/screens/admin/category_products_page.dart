// lib/screens/category_products_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:ecommerce/screens/product_detail_screen.dart';
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
    setState(() => _loading = true);
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
    final catId = widget.category.id.trim();
    final catName = widget.category.name.trim().toLowerCase();
    final filtered = _all.where((p) {
      final prodCat = (p.category ?? '').toString();
      if (prodCat.isEmpty) return false;
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

  Future<void> _addToCart(Product p) async {
    final ok = await CartService.instance.addItem(p.id, qty: 1);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Added to cart' : 'Failed to add to cart')));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1200 ? 4 : width >= 800 ? 3 : width >= 480 ? 2 : 1;
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
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
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // open product detail — use your existing product detail widget
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)));
                                  },
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: p.imageUrl.isNotEmpty
                                        ? Image.network(p.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]))
                                        : Container(color: Colors.grey[200]),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text('₹${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    ElevatedButton.icon(onPressed: () => _addToCart(p), icon: const Icon(Icons.add_shopping_cart_outlined), label: const Text('Add')),
                                    const SizedBox(width: 8),
                                    OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))), child: const Text('Details')),
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
