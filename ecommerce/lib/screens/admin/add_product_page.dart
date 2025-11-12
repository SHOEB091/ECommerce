import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  Uint8List? _webImage;
  XFile? _pickedFile;
  bool _isLoading = false;

  List<Category> _categories = [];
  String? _selectedCategory;

  final String baseUrl = 'http://10.249.13.166:5000/api/products/';
  final String categoryUrl = 'http://10.249.13.166:5000/api/categories/';

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _priceCtrl.text = widget.product!.price.toString();
      _stockCtrl.text = widget.product!.stock.toString();
      _selectedCategory = widget.product!.categoryId;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _pickedFile = picked;
        });
      } else {
        setState(() => _pickedFile = picked);
      }
    }
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final uri = widget.product == null
          ? Uri.parse(baseUrl)
          : Uri.parse('$baseUrl${widget.product!.id}');

      final request = http.MultipartRequest(
        widget.product == null ? 'POST' : 'PUT',
        uri,
      );

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

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: $resBody');

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? '✅ Product added successfully!'
                : '✅ Product updated successfully!'),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ Submit error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Product Details',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) => v!.isEmpty ? 'Enter product name' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (₹)'),
                  validator: (v) => v!.isEmpty ? 'Enter price' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Stock Quantity'),
                  validator: (v) => v!.isEmpty ? 'Enter stock quantity' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _categories.any((c) => c.id == _selectedCategory)
                      ? _selectedCategory
                      : null,
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  decoration:
                      const InputDecoration(labelText: 'Select Category'),
                  validator: (v) =>
                      v == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _pickImage,
                  child: _pickedFile == null && _webImage == null
                      ? Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 50, color: Colors.grey)),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.memory(_webImage!,
                                  height: 180, fit: BoxFit.cover)
                              : Image.network(
                                  widget.product?.image ??
                                      _pickedFile!.path,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                        ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : Text(isEditing ? 'Update Product' : 'Add Product',
                            style: const TextStyle(fontSize: 16)),
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
