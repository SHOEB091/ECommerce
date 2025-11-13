import 'dart:convert';
import 'package:ecommerce/screens/admin/category_model.dart';
import 'package:ecommerce/screens/admin/product_model.dart';
import 'package:http/http.dart' as http;


class ApiService {
  // change this if your backend URL is different / production
  static const String base = 'http://localhost:5000/api';

  static Future<List<Category>> fetchCategories() async {
    final uri = Uri.parse('$base/categories');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      final raw = (body is Map && body.containsKey('data')) ? body['data'] : body;
      return (raw as List).map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories (${res.statusCode})');
  }

  static Future<List<Product>> fetchProducts({String? categoryId}) async {
    final uri = Uri.parse(
      categoryId == null ? '$base/products' : '$base/products?category=$categoryId',
    );
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      final raw = (body is Map && body.containsKey('data')) ? body['data'] : body;
      return (raw as List).map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Failed to load products (${res.statusCode})');
  }
}
