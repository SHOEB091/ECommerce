// lib/services/cart_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Simple result wrapper returned by service methods.
class CartResult {
  final bool success;
  final int? statusCode;
  final String? message;
  final dynamic payload;

  CartResult({
    required this.success,
    this.statusCode,
    this.message,
    this.payload,
  });

  @override
  String toString() {
    return 'CartResult(success: $success, statusCode: $statusCode, message: ${message ?? 'null'}, payload: ${payload ?? 'null'})';
  }
}

/// Model used by UI (matches what UI expects in earlier code)
class CartItem {
  final String id; // cart item id (fallbacks to productId when absent)
  final String productId;
  final String title;
  final String image;
  final int? priceInPaise;
  final double? unitPrice;
  final Map<String, dynamic>? productPayload;
  int qty;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.image,
    required this.qty,
    this.priceInPaise,
    this.unitPrice,
    this.productPayload,
  });

  /// Create a CartItem from backend response.
  /// Handles both populated product objects and simple id references.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final dynamic productNode = json['productId'] ?? json['product'];
    final Map<String, dynamic>? productMap =
        (productNode is Map<String, dynamic>)
        ? productNode
        : (productNode is Map)
        ? Map<String, dynamic>.from(productNode)
        : null;

    final String resolvedProductId =
        productMap?['_id']?.toString() ??
        (productNode != null ? productNode.toString() : '');
    final String resolvedTitle =
        json['title']?.toString() ??
        productMap?['name']?.toString() ??
        json['name']?.toString() ??
        'Item';
    final String resolvedImage =
        json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        productMap?['image']?.toString() ??
        productMap?['imageUrl']?.toString() ??
        '';

    final int? paise = json['priceInPaise'] != null
        ? int.tryParse(json['priceInPaise'].toString())
        : null;
    double? price;
    if (json['price'] != null) {
      price = double.tryParse(json['price'].toString());
    } else if (productMap?['price'] != null) {
      price = double.tryParse(productMap!['price'].toString());
    } else if (paise != null) {
      price = paise / 100.0;
    }

    final int resolvedQty = json['qty'] != null
        ? int.tryParse(json['qty'].toString()) ?? 1
        : (json['quantity'] != null
              ? int.tryParse(json['quantity'].toString()) ?? 1
              : 1);

    final String resolvedId =
        json['id']?.toString() ??
        json['_id']?.toString() ??
        json['cartItemId']?.toString() ??
        resolvedProductId;

    return CartItem(
      id: resolvedId,
      productId: resolvedProductId,
      title: resolvedTitle,
      image: resolvedImage,
      qty: resolvedQty,
      priceInPaise: paise,
      unitPrice: price,
      productPayload: productMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'title': title,
    'image': image,
    'qty': qty,
    if (priceInPaise != null) 'priceInPaise': priceInPaise,
    if (unitPrice != null) 'price': unitPrice,
  };

  // Legacy getters to keep older UI code functioning without immediate refactor.
  String get name => title;
  String get imageUrl => image;
  double get price =>
      unitPrice ?? (priceInPaise != null ? priceInPaise! / 100.0 : 0.0);
}

/// CartService singleton
class CartService {
  CartService._internal();

  static final CartService instance = CartService._internal();

  // runtime configuration
  String _host = 'localhost';
  int _port = 5000;
  String _apiPrefix = '/api/v1';
  bool _useHttps = false;
  String get _baseUrl {
    final protocol = _useHttps ? 'https' : 'http';
    final portPart = (_port != 80 && _port != 443) ? ':$port' : '';
    return '$protocol://$_host$portPart$_apiPrefix';
  }
  String get baseUrl => _baseUrl;

  final _storage = const FlutterSecureStorage();
  String? _token;

  // notifier for UI
  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  // expose a read-only snapshot
  List<CartItem> get currentItems => List.unmodifiable(items.value);

  /// Call early to configure host/port/prefix before init (optional).
  void configure({
    required String host,
    required int port,
    String apiPrefix = '/api/v1',
    bool useHttps = false,
  }) {
    _host = host;
    _port = port;
    _apiPrefix = apiPrefix;
    _useHttps = useHttps;
  }

  /// Initialize: load token (if any) and optionally fetch cart.
  Future<void> init({
    bool fetch = true,
    String? token,
    bool persistToken = true,
  }) async {
    try {
      if (token != null && token.isNotEmpty) {
        await setAuthToken(token, persist: persistToken);
        debugPrint('CartService: token supplied to init() and stored');
      } else {
        _token = await _storage.read(key: 'token');
        if (_token == null || _token!.isEmpty) {
          _token = await _storage.read(key: 'auth_token');
          if (_token != null && _token!.isNotEmpty) {
            debugPrint('CartService: token loaded from auth_token key');
          }
        }
        if (_token != null && _token!.isNotEmpty) {
          debugPrint('CartService: token loaded from storage');
        } else {
          debugPrint('CartService: no token in storage');
        }
      }
      if (fetch) {
        await fetchCart();
      }
    } catch (e, st) {
      debugPrint('CartService.init error: $e\n$st');
    }
  }

  /// Save token to storage and set for subsequent requests.
  Future<void> setAuthToken(String? token, {bool persist = true}) async {
    _token = token;
    if (persist) {
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'auth_token', value: token);
      } else {
        await _storage.delete(key: 'token');
        await _storage.delete(key: 'auth_token');
      }
    }
  }

  Map<String, String> _defaultHeaders() {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Map<String, String> defaultHeaders() => _defaultHeaders();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final url = '$_baseUrl$path';
    if (query == null || query.isEmpty) return Uri.parse(url);
    return Uri.parse(
      url,
    ).replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString())));
  }

  Map<String, dynamic> _mapFromDynamic(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  List<CartItem> _parseCartItems(dynamic payload) {
    try {
      if (payload == null) return [];

      if (payload is List) {
        return payload.map<CartItem>((item) {
          if (item is CartItem) return item;
          return CartItem.fromJson(_mapFromDynamic(item));
        }).toList();
      }

      if (payload is CartItem) {
        return [payload];
      }

      if (payload is Map || payload is Map<String, dynamic>) {
        final map = _mapFromDynamic(payload);

        if (map.containsKey('items') && map['items'] is List) {
          return _parseCartItems(map['items']);
        }
        if (map.containsKey('cart')) {
          return _parseCartItems(map['cart']);
        }
        if (map.containsKey('data')) {
          return _parseCartItems(map['data']);
        }
        if (map.containsKey('result')) {
          return _parseCartItems(map['result']);
        }
        if (map.containsKey('item')) {
          return _parseCartItems(map['item']);
        }
        if (map.containsKey('productId') || map.containsKey('product')) {
          return [CartItem.fromJson(map)];
        }
      }
    } catch (e, st) {
      debugPrint('CartService._parseCartItems error: $e\n$st');
    }
    return [];
  }

  void _updateItemsFromPayload(dynamic payload) {
    items.value = _parseCartItems(payload);
  }

  /// Add item to cart.
  /// Returns CartResult with success flag and statusCode/message
  Future<CartResult?> addItem(String productId, {int qty = 1}) async {
    try {
      final u = _uri('/cart/item');
      final body = json.encode({'productId': productId, 'qty': qty});
      final res = await http
          .post(u, headers: _defaultHeaders(), body: body)
          .timeout(const Duration(seconds: 12));
      final sc = res.statusCode;
      dynamic payload;
      try {
        payload = json.decode(res.body);
      } catch (_) {
        payload = res.body;
      }

      if (sc >= 200 && sc < 300) {
        _updateItemsFromPayload(payload);
        final String message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Added to cart';
        return CartResult(
          success: true,
          statusCode: sc,
          message: message,
          payload: payload,
        );
      }

      if (sc == 401) {
        final String message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Not authorized';
        return CartResult(
          success: false,
          statusCode: sc,
          message: message,
          payload: payload,
        );
      }

      final String message = (payload is Map && payload['message'] != null)
          ? payload['message'].toString()
          : 'Failed to add to cart ($sc)';
      return CartResult(
        success: false,
        statusCode: sc,
        message: message,
        payload: payload,
      );
    } catch (e, st) {
      debugPrint('CartService.addItem error: $e\n$st');
      return CartResult(
        success: false,
        statusCode: null,
        message: 'Network or internal error: $e',
      );
    }
  }

  /// Fetch cart items from server and populate items ValueNotifier.
  /// Returns CartResult
  Future<CartResult> fetchCart() async {
    try {
      final u = _uri('/cart');
      final res = await http
          .get(u, headers: _defaultHeaders())
          .timeout(const Duration(seconds: 12));
      final sc = res.statusCode;
      dynamic payload;
      try {
        payload = json.decode(res.body);
      } catch (_) {
        payload = res.body;
      }

      if (sc >= 200 && sc < 300) {
        _updateItemsFromPayload(payload);
        final String message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Cart fetched';
        return CartResult(
          success: true,
          statusCode: sc,
          message: message,
          payload: items.value,
        );
      }

      items.value = [];

      if (sc == 401) {
        final String message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Not authorized, no token';
        return CartResult(
          success: false,
          statusCode: sc,
          message: message,
          payload: payload,
        );
      }

      final String message = (payload is Map && payload['message'] != null)
          ? payload['message'].toString()
          : 'Failed to fetch cart';
      return CartResult(
        success: false,
        statusCode: sc,
        message: message,
        payload: payload,
      );
    } catch (e, st) {
      debugPrint('CartService.fetchCart error: $e\n$st');
      items.value = [];
      return CartResult(
        success: false,
        statusCode: null,
        message: 'Network or internal error: $e',
      );
    }
  }

  /// Remove a cart item by product id
  Future<CartResult> removeItem(String productId) async {
    try {
      final u = _uri('/cart/item/$productId');
      final res = await http
          .delete(u, headers: _defaultHeaders())
          .timeout(const Duration(seconds: 12));
      final sc = res.statusCode;
      dynamic payload;
      try {
        payload = json.decode(res.body);
      } catch (_) {
        payload = res.body;
      }

      if (sc >= 200 && sc < 300) {
        _updateItemsFromPayload(payload);
        final String message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Removed';
        return CartResult(
          success: true,
          statusCode: sc,
          message: message,
          payload: payload,
        );
      }

      if (sc == 401) {
        final String message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Not authorized';
        return CartResult(
          success: false,
          statusCode: sc,
          message: message,
          payload: payload,
        );
      }

      final String message = (payload is Map && payload['message'] != null)
          ? payload['message'].toString()
          : 'Failed to remove';
      return CartResult(
        success: false,
        statusCode: sc,
        message: message,
        payload: payload,
      );
    } catch (e, st) {
      debugPrint('CartService.removeItem error: $e\n$st');
      return CartResult(
        success: false,
        statusCode: null,
        message: 'Network or internal error: $e',
      );
    }
  }

  /// Update item quantity
  Future<CartResult> updateItemQty(String productId, {required int qty}) async {
    try {
      final u = _uri('/cart/item/$productId');
      final body = json.encode({'qty': qty});
      final res = await http
          .put(u, headers: _defaultHeaders(), body: body)
          .timeout(const Duration(seconds: 12));
      final sc = res.statusCode;
      dynamic payload;
      try {
        payload = json.decode(res.body);
      } catch (_) {
        payload = res.body;
      }

      if (sc >= 200 && sc < 300) {
        _updateItemsFromPayload(payload);
        final String message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Quantity updated';
        return CartResult(
          success: true,
          statusCode: sc,
          message: message,
          payload: payload,
        );
      }

      if (sc == 401) {
        final String message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Not authorized';
        return CartResult(
          success: false,
          statusCode: sc,
          message: message,
          payload: payload,
        );
      }

      final String message = (payload is Map && payload['message'] != null)
          ? payload['message'].toString()
          : 'Failed to update qty';
      return CartResult(
        success: false,
        statusCode: sc,
        message: message,
        payload: payload,
      );
    } catch (e, st) {
      debugPrint('CartService.updateItemQty error: $e\n$st');
      return CartResult(
        success: false,
        statusCode: null,
        message: 'Network or internal error: $e',
      );
    }
  }

  /// Clear all local items (does not call server)
  void clearLocalCart() {
    items.value = [];
  }

  /// Backwards compatible aliases for legacy UI code.
  Future<CartResult> remove(String productId) => removeItem(productId);
  Future<CartResult> updateQty(String productId, int qty) =>
      updateItemQty(productId, qty: qty);

  /// Full sign-out: remove token & clear local cart
  Future<void> signOut() async {
    await setAuthToken(null, persist: true);
    clearLocalCart();
  }
}
