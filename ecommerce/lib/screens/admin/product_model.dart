// lib/screens/admin/product_model.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category; // typically category id (or name) depending on backend
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
  });

  // defensive helper to coerce values to string
  static String _asString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is num) return v.toString();
    if (v is bool) return v ? 'true' : 'false';
    if (v is Map) {
      // common image fields
      if (v.containsKey('secure_url')) return _asString(v['secure_url']);
      if (v.containsKey('url')) return _asString(v['url']);
      if (v.containsKey('path')) return _asString(v['path']);
      if (v.containsKey('imageUrl')) return _asString(v['imageUrl']);
      if (v.containsKey('name')) return _asString(v['name']);
      // fallback: first non-empty value
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

  factory Product.fromJson(Map<String, dynamic> json) {
    // id
    final id = (json['_id'] ?? json['id'] ?? '').toString();

    // name
    final rawName = json['name'] ?? json['title'] ?? '';
    final name = _asString(rawName);

    // description
    final rawDesc = json['description'] ?? '';
    final description = _asString(rawDesc);

    // price (defensive)
    double price = 0.0;
    try {
      final p = json['price'];
      if (p is num) {
        price = p.toDouble();
      } else if (p is String) {
        price = double.tryParse(p) ?? 0.0;
      } else {
        price = 0.0;
      }
    } catch (_) {
      price = 0.0;
    }

    // image - can be string or object
    String imageUrl = '';
    if (json.containsKey('image')) {
      imageUrl = _asString(json['image']);
    } else if (json.containsKey('imageUrl')) {
      imageUrl = _asString(json['imageUrl']);
    } else if (json.containsKey('images')) {
      final imgs = json['images'];
      if (imgs is List && imgs.isNotEmpty) {
        imageUrl = _asString(imgs.first);
      } else {
        imageUrl = _asString(imgs);
      }
    }

    // category - can be id or nested object with name/_id
    String category = '';
    try {
      final c = json['category'];
      if (c == null) {
        category = '';
      } else if (c is String) {
        category = c;
      } else if (c is Map) {
        // prefer id then name
        category = _asString(c['_id'] ?? c['id'] ?? c['name'] ?? c['title'] ?? c);
      } else {
        category = c.toString();
      }
    } catch (_) {
      category = '';
    }

    // stock
    int stock = 0;
    try {
      final s = json['stock'];
      if (s is num) {
        stock = s.toInt();
      } else if (s is String) stock = int.tryParse(s) ?? 0;
    } catch (_) {
      stock = 0;
    }

    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      stock: stock,
    );
  }
}
