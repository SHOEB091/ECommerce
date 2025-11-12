import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_model.dart';
import 'add_product_page.dart';
import 'category_page.dart'; // ✅ Added this import for category management

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  List<Product> products = [];
  final String baseUrl = 'http://localhost:4000/api/products/';

  Future<void> _fetchProducts() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body)['data'];
        setState(() => products = data.map((e) => Product.fromJson(e)).toList());
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  Future<void> _deleteProduct(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Product deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to delete: ${res.body}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1000
        ? 4
        : screenWidth > 700
            ? 3
            : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.blue.shade50,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.admin_panel_settings,
                          size: 30, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text('Admin Dashboard',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Manage store content',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              // ✅ Manage Products
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('Manage Products'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // ✅ Manage Categories
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Manage Categories'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoryPage()),
                  );
                },
              ),

              const Divider(),

              // Future expandable options (e.g., Orders, Analytics)
              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Analytics Dashboard'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('📊 Coming soon: Analytics Dashboard')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
          if (result == true) _fetchProducts();
        },
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.network(
                              product.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('₹${product.price}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddProductPage(product: product),
                                  ),
                                );
                                if (result == true) _fetchProducts();
                              },
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                            ),
                            IconButton(
                              onPressed: () => _deleteProduct(product.id),
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
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
}
