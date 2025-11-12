// lib/screens/admin/products_list_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product_model.dart';
import 'add_product_page.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _getApiBase({int port = 5000}) {
    if (kIsWeb) return 'http://localhost:$port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
    return 'http://localhost:$port/api';
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final uri = Uri.parse('${_getApiBase()}/products');

    try {
      final resp = await http.get(uri, headers: {'Accept': 'application/json'});
      debugPrint('DEBUG GET ${uri.toString()} -> ${resp.statusCode}');
      debugPrint('DEBUG Body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body);
        final raw = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;

        if (raw is List) {
          setState(() {
            _products = raw.map((e) {
              if (e is Map<String, dynamic>) return Product.fromJson(e);
              return Product.fromJson(Map<String, dynamic>.from(e));
            }).toList();
          });
        } else {
          setState(() => _error = 'Unexpected response shape: ${raw.runtimeType}');
        }
      } else {
        setState(() => _error = 'Failed to load products (${resp.statusCode})');
      }
    } catch (e, st) {
      debugPrint('Error fetching products: $e\n$st');
      setState(() => _error = 'Error fetching products: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String id) async {
    final uri = Uri.parse('${_getApiBase()}/products/$id');
    try {
      final res = await http.delete(uri);
      debugPrint('DELETE ${uri.toString()} -> ${res.statusCode}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Product deleted')));
        await _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${res.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
    }
  }

  Future<void> _openAddEdit({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductPage(product: product)),
    );
    if (result == true) {
      await _load();
    }
  }

  Widget _leadingImage(Product p) {
    if (p.imageUrl.isEmpty) return const Icon(Icons.image_outlined, size: 48);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        p.imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () => _openAddEdit(), icon: const Icon(Icons.add)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, style: const TextStyle(color: Colors.red))))
              : _products.isEmpty
                  ? const Center(child: Text('No products yet — add one using the + button'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final p = _products[i];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: _leadingImage(p),
                            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('₹${p.price.toStringAsFixed(2)}  •  Stock: ${p.stock}\nCategory: ${p.category}'),
                            isThreeLine: true,
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openAddEdit(product: p)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(p.id)),
                            ]),
                          ),
                        );
                      },
                    ),
    );
  }
}
