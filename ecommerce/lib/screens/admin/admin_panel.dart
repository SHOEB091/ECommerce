// lib/screens/admin/admin_panel.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product_model.dart';
import 'add_product_page.dart';
import 'category_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<Product> products = [];
  bool _isLoading = false;
  String? _error;

  // platform-aware base
  String _getApiBase({int port = 5000}) {
    if (kIsWeb) return 'http://localhost:$port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
    return 'http://localhost:$port/api';
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final String baseUrl = '${_getApiBase()}/products';
    try {
      final res = await http.get(Uri.parse(baseUrl), headers: {'Accept': 'application/json'});
      debugPrint('DEBUG GET $baseUrl -> ${res.statusCode}');
      debugPrint('DEBUG Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        final raw = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;

        if (raw is List) {
          setState(() {
            products = raw.map<Product>((e) {
              // ensure each item is a Map<String, dynamic>
              if (e is Map<String, dynamic>) return Product.fromJson(e);
              return Product.fromJson(Map<String, dynamic>.from(e));
            }).toList();
          });
        } else {
          setState(() {
            _error = 'Unexpected response shape: ${raw.runtimeType}';
            products = [];
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load products: ${res.statusCode}';
          products = [];
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching products: $e\n$st');
      setState(() {
        _error = 'Error fetching products: ${e.toString()}';
        products = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(String id) async {
    final String url = '${_getApiBase()}/products/$id';
    try {
      final res = await http.delete(Uri.parse(url));
      debugPrint('DEBUG DELETE $url -> ${res.statusCode}');
      debugPrint('DEBUG Body: ${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Product deleted successfully')));
        await _fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Failed to delete: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
    }
  }

  Future<void> _loadAdminInfo() async {
    final name = await _storage.read(key: 'userName');
    final email = await _storage.read(key: 'userEmail');
    setState(() {
      _adminName = name ?? email ?? 'Admin';
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _loadAdminInfo();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteAll();
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('👋 Logged out successfully')),
        );
      }
    }
  }

  Widget _productImage(Product product) {
    if (product.imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey)),
      );
    }

    return Image.network(
      product.imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1000 ? 4 : screenWidth > 700 ? 3 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 8,
        child: SafeArea(
          child: Column(
            children: [
              // 🔷 Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: Colors.blueAccent, child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.white)),
                    SizedBox(height: 10),
                    Text('Admin Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Manage store content', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('Manage Products'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Manage Categories'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryPage()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Analytics Dashboard'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📊 Coming soon: Analytics Dashboard')));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // 🔘 Floating Add Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()));
          if (result == true) _fetchProducts();
        },
        label: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, style: const TextStyle(color: Colors.red))))
              : products.isEmpty
                  ? const Center(child: Text('No products found — add one using the button below.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), clipBehavior: Clip.hardEdge, child: _productImage(product)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('₹${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  ]),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage(product: product)));
                                        if (result == true) _fetchProducts();
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteProduct(product.id),
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: Colors.blue.shade50,
    );
  }
}
