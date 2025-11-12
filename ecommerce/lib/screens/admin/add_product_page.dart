// lib/screens/admin/add_product_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'product_model.dart';
import 'category_model.dart';
import 'package:flutter/services.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  Uint8List? _webImage;
  XFile? _pickedFile;
  bool _isLoading = false;

  List<Category> _categories = [];
  String? _selectedCategory;

  late final String baseUrl; // products
  late final String categoryUrl;

  @override
  void initState() {
    super.initState();
    baseUrl = _getApiBase() + '/products';
    categoryUrl = _getApiBase() + '/categories';
    _fetchCategories();

    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _priceCtrl.text = widget.product!.price.toString();
      _stockCtrl.text = widget.product!.stock.toString();
      // product.category might be id or object — handle both:
      final cat = widget.product!.category;
      if (cat != null && cat.isNotEmpty) {
        _selectedCategory = cat;
      }
    }
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
    if (v is Map) {
      if (v.containsKey('_id')) return v['_id']?.toString() ?? '';
      if (v.containsKey('id')) return v['id']?.toString() ?? '';
      if (v.containsKey('name')) return v['name']?.toString() ?? '';
      if (v.containsKey('secure_url')) return v['secure_url']?.toString() ?? '';
      for (final val in v.values) {
        if (val != null) return val.toString();
      }
      return v.toString();
    }
    return v.toString();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } on PlatformException catch (e) {
      debugPrint('Image pick failed: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await http.get(Uri.parse(categoryUrl));
      debugPrint('DEBUG GET ${categoryUrl} -> ${res.statusCode}');
      debugPrint('DEBUG Response body: ${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        List raw;
        if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
          raw = decoded['data'];
        } else if (decoded is List) {
          raw = decoded;
        } else if (decoded is Map && decoded.containsKey('categories') && decoded['categories'] is List) {
          raw = decoded['categories'];
        } else {
          raw = [];
        }

        setState(() {
          _categories = raw.map((e) {
            final id = (e is Map && (e['_id'] != null || e['id'] != null)) ? ((e['_id'] ?? e['id']).toString()) : '';
            final name = (e is Map && e.containsKey('name')) ? _asString(e['name']) : (e is Map && e.containsKey('title') ? _asString(e['title']) : _asString(e));
            return Category(id: id, name: name);
          }).toList();
        });
      }
    } catch (e, st) {
      debugPrint('Error loading categories: $e\n$st');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final uri = widget.product == null ? Uri.parse(baseUrl) : Uri.parse('$baseUrl/${widget.product!.id}');
    final request = http.MultipartRequest(widget.product == null ? 'POST' : 'PUT', uri);

      request.fields['name'] = _nameCtrl.text.trim();
      request.fields['description'] = _descCtrl.text.trim();
      request.fields['price'] = _priceCtrl.text.trim();
      request.fields['stock'] = _stockCtrl.text.trim();
      request.fields['category'] = _selectedCategory ?? '';

      if (_pickedFile != null) {
        if (kIsWeb && _webImage != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            _webImage!,
            filename: _pickedFile!.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath('image', _pickedFile!.path));
        }
      }

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      debugPrint('DEBUG ${request.method} ${uri.toString()} -> ${response.statusCode}');
      debugPrint('DEBUG Response body: $resBody');

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Product saved successfully!')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $resBody')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error submitting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting product: $e')));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Product Name'), validator: (v) => v!.isEmpty ? 'Enter product name' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextFormField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)'), validator: (v) => v!.isEmpty ? 'Enter price' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock Quantity'), validator: (v) => v!.isEmpty ? 'Enter stock quantity' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem<String>(value: cat.id, child: Text(cat.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                decoration: const InputDecoration(labelText: 'Select Category'),
                validator: (v) => v == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? Container(height: 180, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey)))
                    : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_image!, height: 180, fit: BoxFit.cover)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(widget.product == null ? 'Add Product' : 'Update Product', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
