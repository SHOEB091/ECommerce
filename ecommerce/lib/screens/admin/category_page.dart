// lib/screens/admin/category_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'category_model.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final String baseUrl;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    baseUrl = '${_getApiBase()}/categories';
    _fetchCategories();
  }

  String _getApiBase({int port = 5000}) {
    if (kIsWeb) return 'http://localhost:$port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
    return 'http://localhost:$port/api';
  }

  String _asString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is num) return v.toString();
    if (v is bool) return v ? 'true' : 'false';
    if (v is Map) {
      if (v.containsKey('secure_url')) return _asString(v['secure_url']);
      if (v.containsKey('url')) return _asString(v['url']);
      if (v.containsKey('name')) return _asString(v['name']);
      for (final val in v.values) {
        final s = _asString(val);
        if (s.isNotEmpty) return s;
      }
      return v.toString();
    }
    try {
      return v.toString();
    } catch (_) {
      return '';
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final uri = Uri.parse(baseUrl);
    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      debugPrint('DEBUG GET ${uri.toString()} -> ${res.statusCode}');
      debugPrint('DEBUG Response body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final dynamic decoded = jsonDecode(res.body);
        List raw;
        if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
          raw = decoded['data'];
        } else if (decoded is List) {
          raw = decoded;
        } else if (decoded is Map && decoded.containsKey('categories') && decoded['categories'] is List) {
          raw = decoded['categories'];
        } else {
          throw Exception('Unexpected response shape');
        }

        setState(() {
          _categories = raw.map((e) {
            final id = (e is Map && (e['_id'] != null || e['id'] != null))
                ? ((e['_id'] ?? e['id']).toString())
                : '';
            final nameRaw = (e is Map && e.containsKey('name')) ? e['name'] : (e is Map && e.containsKey('title') ? e['title'] : e);
            final name = _asString(nameRaw);
            return Category(id: id, name: name);
          }).toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load categories: ${res.statusCode}';
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching categories: $e\n$st');
      setState(() {
        _error = 'Error fetching categories: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final uri = Uri.parse(baseUrl);
    try {
      final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': name}));
      debugPrint('DEBUG POST ${uri.toString()} -> ${res.statusCode}');
      debugPrint('DEBUG Response body: ${res.body}');
      if (res.statusCode == 201 || res.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Category added successfully')));
        await _fetchCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Failed to add: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Error adding category: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding category: $e')));
    }
  }

  Future<void> _updateCategory(String id, String newName) async {
    final uri = Uri.parse('$baseUrl/$id');
    try {
      final res = await http.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': newName}));
      debugPrint('DEBUG PUT ${uri.toString()} -> ${res.statusCode}');
      debugPrint('DEBUG Response body: ${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Category updated')));
        await _fetchCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Update failed: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating category: $e')));
    }
  }

  Future<void> _deleteCategory(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    try {
      final res = await http.delete(uri);
      debugPrint('DEBUG DELETE ${uri.toString()} -> ${res.statusCode}');
      debugPrint('DEBUG Response body: ${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Category deleted')));
        await _fetchCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Failed: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting category: $e')));
    }
  }

  void _showCategoryDialog({String? id, String? initialName}) {
    _nameController.text = initialName ?? '';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(id == null ? 'Add Category' : 'Edit Category'),
          content: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Category Name')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showCategoryDialog())],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _categories.isEmpty
                  ? const Center(child: Text('No categories found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.category_outlined),
                            title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showCategoryDialog(id: category.id, initialName: category.name)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCategory(category.id)),
                            ]),
                          ),
                        );
                      },
                    ),
    );
  }
}
