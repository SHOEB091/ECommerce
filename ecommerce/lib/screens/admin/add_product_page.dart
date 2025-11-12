import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'product_model.dart';
import 'category_model.dart';

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

  File? _image;
  bool _isLoading = false;

  List<Category> _categories = [];
  String? _selectedCategory;

  final String baseUrl = 'http://localhost:5000/api/products';
  final String categoryUrl = 'http://localhost:5000/api/categories';

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _priceCtrl.text = widget.product!.price.toString();
      _stockCtrl.text = widget.product!.stock.toString();
      _selectedCategory = widget.product!.category;
    }
  }

  // 🔹 Pick image from gallery
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // 🔹 Fetch categories from backend
  Future<void> _fetchCategories() async {
    try {
      final res = await http.get(Uri.parse(categoryUrl));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body)['data'];
        setState(() {
          _categories = data.map((e) => Category.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  // 🔹 Submit form to backend
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final uri = widget.product == null
        ? Uri.parse(baseUrl)
        : Uri.parse('$baseUrl/${widget.product!.id}');

    final request = http.MultipartRequest(
      widget.product == null ? 'POST' : 'PUT',
      uri,
    );

    request.fields['name'] = _nameCtrl.text.trim();
    request.fields['description'] = _descCtrl.text.trim();
    request.fields['price'] = _priceCtrl.text.trim();
    request.fields['stock'] = _stockCtrl.text.trim();
    request.fields['category'] = _selectedCategory ?? '';

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    final response = await request.send();
    setState(() => _isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Product saved successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${response.reasonPhrase}')),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),

                // 🏷️ Product Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) => v!.isEmpty ? 'Enter product name' : null,
                ),
                const SizedBox(height: 12),

                // 🧾 Description
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),

                // 💰 Price
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (₹)'),
                  validator: (v) => v!.isEmpty ? 'Enter price' : null,
                ),
                const SizedBox(height: 12),

                // 📦 Stock
                TextFormField(
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                  validator: (v) => v!.isEmpty ? 'Enter stock quantity' : null,
                ),
                const SizedBox(height: 12),

                // 🗂️ Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  decoration: const InputDecoration(labelText: 'Select Category'),
                  validator: (v) => v == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 20),

                // 🖼️ Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: _image == null
                      ? Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Center(
                            child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, height: 180, fit: BoxFit.cover),
                        ),
                ),
                const SizedBox(height: 24),

                // ✅ Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.product == null ? 'Add Product' : 'Update Product',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
