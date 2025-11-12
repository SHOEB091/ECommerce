// lib/services/cart_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class CartItem {
  final String id; // productId string
  final String title;
  final String? image;
  final int priceInPaise; // integer paise
  int qty;

  CartItem({
    required this.id,
    required this.title,
    this.image,
    required this.priceInPaise,
    this.qty = 1,
  });

  Map<String, dynamic> toJson() => {
        'productId': id,
        'title': title,
        'image': image,
        'priceInPaise': priceInPaise,
        'qty': qty,
      };

  static CartItem fromJson(Map<String, dynamic> j) {
    final productId = (j['productId'] ?? j['id'] ?? '').toString();
    final title = (j['title'] ?? j['name'] ?? '').toString();
    final image = j['image']?.toString();
    final priceInPaise =
        _toInt(j['priceInPaise'] ?? j['price_paise'] ?? j['price'] ?? 0);
    final qty = _toInt(j['qty'] ?? j['quantity'] ?? 1);

    return CartItem(
      id: productId,
      title: title,
      image: image,
      priceInPaise: priceInPaise,
      qty: qty,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) {
      final parsed = int.tryParse(v);
      if (parsed != null) return parsed;
      final d = double.tryParse(v);
      if (d != null) return d.round();
    }
    return 0;
  }
}

class CartService {
  CartService._();
  static final instance = CartService._();

  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);
  static const _kStorageKey = 'app_cart_v1';
  bool _initialized = false;

  String get _base {
    // Priority: explicit env override -> web localhost -> android emulator -> localhost fallback
    final fromEnv = dotenv.env['API_BASE'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

    // Web builds can reach the backend at localhost when run on same machine
    if (kIsWeb) return 'http://localhost:5000/api/v1';

    // Android emulator uses 10.0.2.2 to reach host machine's localhost
    return 'http://10.0.2.2:5000/api/v1';
  }

  Map<String, String> _defaultHeaders([String? token]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// Call once at app startup
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFromStorage();
    await _trySyncFromServer();
  }

  Future<void> _trySyncFromServer() async {
    try {
      final r = await _apiGet('/cart');
      if (r == null) return;
      final status = r['status'] as int? ?? 0;
      final body = r['body'];
      if (status == 200 && body != null && body['cart'] != null) {
        final cartJson = body['cart'] as Map<String, dynamic>;
        final itemsJson = cartJson['items'] as List<dynamic>? ?? [];
        final remote = <CartItem>[];
        for (final e in itemsJson) {
          try {
            final m = Map<String, dynamic>.from(e as Map);
            final pid = (m['productId'] is Map)
                ? (m['productId']['_id'] ?? m['productId']['id'])
                : m['productId'];
            final entry = {
              'productId': pid,
              'title': m['title'] ??
                  (m['productId'] is Map ? m['productId']['name'] : null),
              'image': m['image'] ??
                  (m['productId'] is Map ? m['productId']['image'] : null),
              'priceInPaise': m['priceInPaise'] ?? m['price'] ?? null,
              'qty': m['qty'] ?? m['quantity'] ?? 1,
            };
            remote.add(CartItem.fromJson(entry));
          } catch (err) {
            debugPrint('[CartService] skip remote item parse: $err');
          }
        }

        // merge remote + local
        final Map<String, CartItem> merged = {};
        for (final it in remote) merged[it.id] = it;
        for (final it in items.value) {
          if (merged.containsKey(it.id)) merged[it.id]!.qty += it.qty;
          else merged[it.id] = it;
        }
        final mergedList = merged.values.toList();
        items.value = mergedList;
        await _saveToStorage(mergedList);

        // push merged to server (best-effort)
        for (final it in mergedList) {
          try {
            await _apiPost('/cart/item', {'productId': it.id, 'qty': it.qty});
          } catch (e) {
            debugPrint('[CartService] push merged item failed: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[CartService] remote sync failed: $e');
    }
  }

  void addToCart(CartItem item, {int addQty = 1}) {
    if (addQty <= 0) addQty = 1;
    final list = List<CartItem>.from(items.value);
    final idx = list.indexWhere((c) => c.id == item.id);
    if (idx >= 0) {
      list[idx].qty = (list[idx].qty + addQty);
    } else {
      final clone = CartItem(
          id: item.id,
          title: item.title,
          image: item.image,
          priceInPaise: item.priceInPaise,
          qty: addQty);
      list.insert(0, clone);
    }
    items.value = list;
    _saveToStorage(list);

    // push to server (best-effort)
    _apiPost('/cart/item', {'productId': item.id, 'qty': addQty})
        .catchError((e) => debugPrint('[CartService] push add failed: $e'));
  }

  Future<void> updateQty(String productId, int qty) async {
    final list = items.value.map((c) {
      if (c.id == productId) c.qty = qty;
      return c;
    }).where((c) => c.qty > 0).toList();

    items.value = list;
    _saveToStorage(list);

    try {
      await _apiPut('/cart/item/$productId', {'qty': qty});
    } catch (e) {
      debugPrint('[CartService] push update failed: $e');
    }
  }

  Future<void> remove(String productId) async {
    final list = items.value.where((c) => c.id != productId).toList();
    items.value = list;
    _saveToStorage(list);

    try {
      await _apiDelete('/cart/item/$productId');
    } catch (e) {
      debugPrint('[CartService] push remove failed: $e');
    }
  }

  Future<void> clear() async {
    items.value = [];
    _saveToStorage([]);
    try {
      await _apiDelete('/cart');
    } catch (e) {
      debugPrint('[CartService] push clear failed: $e');
    }
  }

  int get totalPaise =>
      items.value.fold(0, (s, c) => s + c.priceInPaise * c.qty);
  int get itemCount => items.value.fold(0, (s, c) => s + c.qty);

  Future<void> _saveToStorage(List<CartItem> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList(_kStorageKey, jsonList);
    } catch (e) {
      debugPrint('[CartService] save error: $e');
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_kStorageKey);
      if (saved == null || saved.isEmpty) {
        items.value = [];
        return;
      }
      final list = <CartItem>[];
      for (final s in saved) {
        try {
          final m = jsonDecode(s) as Map<String, dynamic>;
          list.add(CartItem.fromJson(m));
        } catch (e) {
          debugPrint('[CartService] decode saved item error: $e');
        }
      }
      items.value = list;
    } catch (e) {
      debugPrint('[CartService] load error: $e');
      items.value = [];
    }
  }

  // -------------------------
  // Internal HTTP helpers
  // -------------------------
  Future<Map<String, dynamic>?> _apiGet(String path, {String? token}) async {
    try {
      final url = '$_base$path';
      final headers = _defaultHeaders(token);
      final resp = await http.get(Uri.parse(url), headers: headers);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return {
          'status': resp.statusCode,
          'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null
        };
      } else {
        debugPrint('[CartService] GET ${resp.statusCode}: ${resp.body}');
        return {'status': resp.statusCode, 'body': resp.body};
      }
    } catch (e) {
      debugPrint('[CartService] _apiGet error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _apiPost(String path, Map<String, dynamic> body,
      {String? token}) async {
    final url = '$_base$path';
    final headers = _defaultHeaders(token);
    final resp =
        await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return {
        'status': resp.statusCode,
        'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null
      };
    } else {
      throw Exception('POST ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<Map<String, dynamic>> _apiPut(String path, Map<String, dynamic> body,
      {String? token}) async {
    final url = '$_base$path';
    final headers = _defaultHeaders(token);
    final resp =
        await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return {
        'status': resp.statusCode,
        'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null
      };
    } else {
      throw Exception('PUT ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<Map<String, dynamic>> _apiDelete(String path, {String? token}) async {
    final url = '$_base$path';
    final headers = _defaultHeaders(token);
    final resp = await http.delete(Uri.parse(url), headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return {
        'status': resp.statusCode,
        'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null
      };
    } else {
      throw Exception('DELETE ${resp.statusCode}: ${resp.body}');
    }
  }
}
