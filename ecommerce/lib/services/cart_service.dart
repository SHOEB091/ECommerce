// lib/services/cart_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Simple CartItem model used in the frontend
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

  /// Live list of cart items (UI should listen to this)
  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  /// integer total in paise (kept as int for backward compatibility
  /// with existing UI that expects an int).
  int totalPaise = 0;

  // Internal state
  String? _token;
  String _apiPrefix = '/api';
  int _port = 5000;
  String _host = 'localhost';

  /// Configure base api prefix and port (call once at startup)
  void configure({String apiPrefix = '/api', int port = 5000, String host = 'localhost'}) {
    _apiPrefix = apiPrefix;
    _port = port;
    _host = host;
  }

  String _base() {
    // prefer emulator-friendly host resolution
    if (kIsWeb) return 'http://$_host:$_port$_apiPrefix';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_port$_apiPrefix';
    return 'http://$_host:$_port$_apiPrefix';
  }

  Map<String, String> _headers() {
    final headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  /// Initialize service with optional JWT token and fetch cart.
  Future<void> init({String? token}) async {
    _token = token;
    await fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      final url = '${_base()}/cart';
      final res = await http.get(Uri.parse(url), headers: _headers());
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final cart = decoded['cart'] ?? decoded;
        final itemsRaw = cart is Map ? (cart['items'] ?? []) : (decoded['items'] ?? []);
        final list = <CartItem>[];
        for (final i in itemsRaw) {
          try {
            list.add(CartItem.fromJson(i));
          } catch (_) {}
        }
        items.value = list;
        _recomputeTotal();
      } else {
        // unauthorized or missing -> clear
        items.value = [];
        totalPaise = 0;
      }
    } catch (e) {
      debugPrint('CartService.fetchCart error: $e');
    }
  }

  Future<bool> addItem(String productId, {int qty = 1}) async {
    try {
      final url = '${_base()}/cart/item';
      final res = await http.post(Uri.parse(url), headers: _headers(), body: json.encode({'productId': productId, 'qty': qty}));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final cart = decoded['cart'] ?? decoded;
        final itemsRaw = cart is Map ? (cart['items'] ?? []) : (decoded['items'] ?? []);
        final list = <CartItem>[];
        for (final i in itemsRaw) {
          try {
            list.add(CartItem.fromJson(i));
          } catch (_) {}
        }
        items.value = list;
        _recomputeTotal();
        return true;
      } else {
        debugPrint('CartService.addItem failed: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('CartService.addItem error: $e');
      return false;
    }
  }

  Future<bool> updateQty(String productId, int qty) async {
    try {
      final url = '${_base()}/cart/item/$productId';
      final res = await http.put(Uri.parse(url), headers: _headers(), body: json.encode({'qty': qty}));
      if (res.statusCode == 200) {
        await fetchCart();
        return true;
      } else {
        debugPrint('CartService.updateQty failed: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('CartService.updateQty error: $e');
      return false;
    }
  }

  Future<bool> remove(String productId) async {
    try {
      final url = '${_base()}/cart/item/$productId';
      final res = await http.delete(Uri.parse(url), headers: _headers());
      if (res.statusCode == 200) {
        await fetchCart();
        return true;
      } else {
        debugPrint('CartService.remove failed: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('CartService.remove error: $e');
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      final url = '${_base()}/cart';
      final res = await http.delete(Uri.parse(url), headers: _headers());
      if (res.statusCode == 200) {
        items.value = [];
        totalPaise = 0;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('CartService.clear error: $e');
      return false;
    }
  }

  void _recomputeTotal() {
    var sum = 0;
    for (final it in items.value) sum += (it.priceInPaise * it.qty);
    totalPaise = sum;
  }
}
