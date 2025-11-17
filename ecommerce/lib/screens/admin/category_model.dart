// lib/screens/admin/category_model.dart
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  static String _asString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is num) return v.toString();
    if (v is Map) {
      if (v.containsKey('name')) return _asString(v['name']);
      if (v.containsKey('value')) return _asString(v['value']);
      for (final val in v.values) {
        final s = _asString(val);
        if (s.isNotEmpty) return s;
      }
      return v.toString();
    }
    return v.toString();
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final rawName = json['name'] ?? json['title'] ?? json;
    final name = _asString(rawName);
    return Category(id: id, name: name);
  }
}
