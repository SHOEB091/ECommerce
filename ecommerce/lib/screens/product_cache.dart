// lib/services/product_cache.dart
import 'package:ecommerce/screens/admin/product_model.dart';

class ProductCache {
  ProductCache._internal();
  static final ProductCache instance = ProductCache._internal();

  final Map<String, List<Product>> _byCategory = {};
  final Map<String, Product> _byId = {};

  bool hasCategory(String categoryId) => _byCategory.containsKey(categoryId);
  List<Product>? getCategory(String categoryId) => _byCategory[categoryId];
  void setCategory(String categoryId, List<Product> products) {
    _byCategory[categoryId] = products;
    for (final p in products) _byId[p.id] = p;
  }

  Product? getById(String id) => _byId[id];
  void clear() {
    _byCategory.clear();
    _byId.clear();
  }
}
