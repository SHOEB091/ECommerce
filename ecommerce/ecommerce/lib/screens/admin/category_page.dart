import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'category_model.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final String baseUrl = 'http://localhost:4000/api/categories';
  List<Category> _categories = [];
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // 🔹 Fetch all categories from backend
  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body)['data'];
        setState(() {
          _categories = data.map((e) => Category.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Add new category
  Future<void> _addCategory() async {
    if (_nameController.text.trim().isEmpty) return;

    final body = {'name': _nameController.text.trim()};

    try {
      final res = await http.post(Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));

      if (res.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ Category added successfully')));
        _fetchCategories();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ Failed: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  // 🔹 Update existing category
  Future<void> _updateCategory(String id, String newName) async {
    try {
      final res = await http.put(Uri.parse('$baseUrl/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': newName}));

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ Category updated')));
        _fetchCategories();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ Update failed: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  // 🔹 Delete category
  Future<void> _deleteCategory(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/$id'));
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('🗑️ Category deleted')));
        _fetchCategories();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ Failed: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }

  // 🔹 Show Add/Edit Dialog
  void _showCategoryDialog({String? id, String? initialName}) {
    _nameController.text = initialName ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(id == null ? 'Add Category' : 'Edit Category'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (id == null) {
                  _addCategory();
                } else {
                  _updateCategory(id, _nameController.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: Text(id == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: Text(category.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showCategoryDialog(
                                id: category.id,
                                initialName: category.name,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(category.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
