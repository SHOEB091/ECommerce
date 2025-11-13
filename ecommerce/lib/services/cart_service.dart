// lib/services/cart_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Rich result used by the service methods
class CartResult {
  final bool success;
  final String message;
  final int? statusCode;
  final dynamic data;

  CartResult({required this.success, required this.message, this.statusCode, this.data});

  @override
  String toString() => 'CartResult(success: $success, status: $statusCode, message: $message)';
}

/// Simple CartItem model used in the frontend (kept compatibility with your existing UI)
class CartItem {
  final String id; // product id
  final String title;
  final String? image;
  final int qty;
  final int priceInPaise;

  CartItem({
    required this.id,
    required this.title,
    required this.qty,
    required this.priceInPaise,
    this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['productId'] ?? json['product'] ?? {};
    final productId = product is Map ? (product['_id'] ?? product['id'] ?? '') : (json['productId'] ?? '');
    final name = (product is Map ? (product['name'] ?? '') : (json['title'] ?? ''));
    final price = (product is Map ? (product['price'] ?? 0) : (json['price'] ?? 0));
    final image = (product is Map ? (product['image'] ?? '') : (json['image'] ?? ''));
    final qty = json['qty'] ?? 1;
    final priceInPaise = json['priceInPaise'] ?? ((price is num) ? ((price * 100).round()) : 0);
    return CartItem(
      id: productId.toString(),
      title: name.toString(),
      qty: qty is int ? qty : int.parse(qty.toString()),
      priceInPaise: priceInPaise is int ? priceInPaise : int.parse(priceInPaise.toString()),
      image: image.toString().isEmpty ? null : image.toString(),
    );
  }
}

class CartService {
  CartService._private();
  static final CartService instance = CartService._private();

  // UI list for listeners
  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);
  int totalPaise = 0;

  // storage for token (optional)
  final _secureStorage = const FlutterSecureStorage();

  // default host + api prefix reflect your server mounting in server.js (/api/v1)
  String _host = 'localhost';
  int _port = 5000;
  String _apiPrefix = '/api/v1';

  String? _token; // in-memory token (if set)

  /// Call at app startup to configure host/port/prefix (optional)
  void configure({String host = 'localhost', int port = 5000, String apiPrefix = '/api/v1'}) {
    _host = host;
    _port = port;
    _apiPrefix = apiPrefix;
  }

  /// call after login to set token and optionally fetch cart
  Future<void> init({String? token, bool fetch = true}) async {
    if (token != null && token.isNotEmpty) {
      _token = token;
      // save token in secure storage for later app restarts
      try {
        await _secureStorage.write(key: 'token', value: token);
      } catch (e) {
        debugPrint('CartService: unable to persist token: $e');
      }
    } else {
      // attempt to load a persisted token if present
      try {
        final stored = await _secureStorage.read(key: 'token');
        if (stored != null && stored.isNotEmpty) _token = stored;
      } catch (e) {
        debugPrint('CartService: error reading token: $e');
      }
    }

    if (fetch) await fetchCart();
  }

  /// Manual token write (e.g. when logging out)
  Future<void> setToken(String? token) async {
    _token = token;
    if (token == null) {
      try {
        await _secureStorage.delete(key: 'token');
      } catch (_) {}
    } else {
      try {
        await _secureStorage.write(key: 'token', value: token);
      } catch (_) {}
    }
  }

  String _base() {
    if (kIsWeb) return 'http://$_host:$_port$_apiPrefix';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_port$_apiPrefix';
    return 'http://$_host:$_port$_apiPrefix';
  }

  Map<String, String> _headers() {
    final headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  // ---------- Operations return CartResult for helpful UI messages ----------

  /// Fetch cart from server and populate items notifier.
  Future<CartResult> fetchCart() async {
    try {
      final url = '${_base()}/cart';
      final res = await http.get(Uri.parse(url), headers: _headers()).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final cart = (decoded is Map && decoded.containsKey('cart')) ? decoded['cart'] : decoded;
        final itemsRaw = cart is Map ? (cart['items'] ?? []) : (decoded['items'] ?? []);
        final list = <CartItem>[];
        for (final i in itemsRaw) {
          try {
            if (i is Map<String, dynamic>) {
              list.add(CartItem.fromJson(i));
            } else if (i is Map) {
              list.add(CartItem.fromJson(Map<String, dynamic>.from(i)));
            }
          } catch (e) {
            debugPrint('CartService.fetchCart: skip item parse error: $e');
          }
        }
        items.value = list;
        _recomputeTotal();
        return CartResult(success: true, message: 'Fetched cart', statusCode: res.statusCode, data: list);
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        // auth required: clear local cart
        items.value = [];
        totalPaise = 0;
        return CartResult(success: false, message: 'Authentication required', statusCode: res.statusCode);
      } else if (res.statusCode == 404) {
        return CartResult(success: false, message: 'Cart route not found (404). Check backend path.', statusCode: res.statusCode);
      } else {
        return CartResult(success: false, message: 'Failed to fetch cart (${res.statusCode})', statusCode: res.statusCode);
      }
    } catch (e) {
      debugPrint('CartService.fetchCart error: $e');
      return CartResult(success: false, message: 'Network error fetching cart: $e');
    }
  }

  /// Try adding an item to the cart. Returns CartResult to inspect reason on failure.
  Future<CartResult> addItem(String productId, {int qty = 1}) async {
    try {
      // your backend expects POST /api/v1/cart/item (based on server.js)
      final url = '${_base()}/cart/item';
      final body = json.encode({'productId': productId, 'qty': qty});
      final res = await http.post(Uri.parse(url), headers: _headers(), body: body).timeout(const Duration(seconds: 10));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // parse and update local cart
        try {
          final decoded = json.decode(res.body);
          final cart = (decoded is Map && decoded.containsKey('cart')) ? decoded['cart'] : decoded;
          final itemsRaw = cart is Map ? (cart['items'] ?? []) : (decoded['items'] ?? []);
          final list = <CartItem>[];
          for (final i in itemsRaw) {
            try {
              if (i is Map<String, dynamic>) list.add(CartItem.fromJson(i));
              else if (i is Map) list.add(CartItem.fromJson(Map<String, dynamic>.from(i)));
            } catch (e) {
              debugPrint('CartService.addItem: skip item parse error: $e');
            }
          }
          items.value = list;
          _recomputeTotal();
          return CartResult(success: true, message: 'Added to cart', statusCode: res.statusCode, data: decoded);
        } catch (e) {
          return CartResult(success: true, message: 'Added to cart (no cart payload parsed)', statusCode: res.statusCode);
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        return CartResult(success: false, message: _extractMessageSafe(res.body) ?? 'Authentication required', statusCode: res.statusCode);
      } else if (res.statusCode == 404) {
        return CartResult(success: false, message: 'Cart endpoint not found (404) — backend route mismatch', statusCode: 404);
      } else {
        return CartResult(success: false, message: _extractMessageSafe(res.body) ?? 'Failed to add item (${res.statusCode})', statusCode: res.statusCode);
      }
    } catch (e) {
      debugPrint('CartService.addItem error: $e');
      return CartResult(success: false, message: 'Network error: $e');
    }
  }

  /// Backwards-compatible helper for code expecting bool
  Future<bool> addItemBool(String productId, {int qty = 1}) async {
    final r = await addItem(productId, qty: qty);
    return r.success;
  }

  Future<CartResult> updateQty(String productId, int qty) async {
    try {
      final url = '${_base()}/cart/item/$productId';
      final res = await http.put(Uri.parse(url), headers: _headers(), body: json.encode({'qty': qty})).timeout(const Duration(seconds: 10));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        await fetchCart();
        return CartResult(success: true, message: 'Updated quantity', statusCode: res.statusCode);
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        return CartResult(success: false, message: 'Authentication required', statusCode: res.statusCode);
      } else if (res.statusCode == 404) {
        return CartResult(success: false, message: 'Cart update route not found (404)', statusCode: res.statusCode);
      } else {
        return CartResult(success: false, message: _extractMessageSafe(res.body) ?? 'Failed to update qty (${res.statusCode})', statusCode: res.statusCode);
      }
    } catch (e) {
      debugPrint('CartService.updateQty error: $e');
      return CartResult(success: false, message: 'Network error: $e');
    }
  }

  Future<CartResult> remove(String productId) async {
    try {
      final url = '${_base()}/cart/item/$productId';
      final res = await http.delete(Uri.parse(url), headers: _headers()).timeout(const Duration(seconds: 10));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        await fetchCart();
        return CartResult(success: true, message: 'Removed from cart', statusCode: res.statusCode);
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        return CartResult(success: false, message: 'Authentication required', statusCode: res.statusCode);
      } else if (res.statusCode == 404) {
        return CartResult(success: false, message: 'Cart delete route not found (404)', statusCode: res.statusCode);
      } else {
        return CartResult(success: false, message: _extractMessageSafe(res.body) ?? 'Failed to remove (${res.statusCode})', statusCode: res.statusCode);
      }
    } catch (e) {
      debugPrint('CartService.remove error: $e');
      return CartResult(success: false, message: 'Network error: $e');
    }
  }

  Future<CartResult> clear() async {
    try {
      final url = '${_base()}/cart';
      final res = await http.delete(Uri.parse(url), headers: _headers()).timeout(const Duration(seconds: 10));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        items.value = [];
        totalPaise = 0;
        return CartResult(success: true, message: 'Cleared cart', statusCode: res.statusCode);
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        return CartResult(success: false, message: 'Authentication required', statusCode: res.statusCode);
      } else if (res.statusCode == 404) {
        return CartResult(success: false, message: 'Clear cart route not found (404)', statusCode: res.statusCode);
      } else {
        return CartResult(success: false, message: _extractMessageSafe(res.body) ?? 'Failed to clear (${res.statusCode})', statusCode: res.statusCode);
      }
    } catch (e) {
      debugPrint('CartService.clear error: $e');
      return CartResult(success: false, message: 'Network error: $e');
    }
  }

  // ---------- helpers ----------
  void _recomputeTotal() {
    var sum = 0;
    for (final it in items.value) {
      sum += (it.priceInPaise * it.qty);
    }
    totalPaise = sum;
  }

  String? _extractMessageSafe(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      final j = json.decode(body);
      if (j is Map && j['message'] != null) return j['message'].toString();
      if (j is Map && j['error'] != null) return j['error'].toString();
    } catch (_) {}
    return body;
  }
}
