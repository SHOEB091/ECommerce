import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cart_service.dart';

class OrderItemSummary {
  final String productId;
  final String name;
  final int qty;
  final double price; // rupees

  OrderItemSummary({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
  });

  factory OrderItemSummary.fromJson(Map<String, dynamic> json) {
    return OrderItemSummary(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? 'Item').toString(),
      qty: int.tryParse(json['qty']?.toString() ?? '') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
    );
  }
}

class OrderAddress {
  final String fullName;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postalCode;
  final String phone;

  OrderAddress({
    required this.fullName,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.phone,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      fullName: (json['fullName'] ?? '').toString(),
      line1: (json['line1'] ?? '').toString(),
      line2: (json['line2'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      postalCode: (json['postalCode'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
    );
  }

  bool get isEmpty => [
    fullName,
    line1,
    city,
    postalCode,
    phone,
  ].every((element) => element.isEmpty);
}

class OrderSummary {
  final String id;
  final DateTime createdAt;
  final String status;
  final List<OrderItemSummary> items;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? receipt;
  final OrderAddress? shippingAddress;

  OrderSummary({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.receipt,
    this.shippingAddress,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final itemsList = <OrderItemSummary>[];
    if (itemsRaw is List) {
      for (final it in itemsRaw) {
        if (it is Map<String, dynamic>) {
          itemsList.add(OrderItemSummary.fromJson(it));
        } else if (it is Map) {
          itemsList.add(
            OrderItemSummary.fromJson(Map<String, dynamic>.from(it)),
          );
        }
      }
    }

    return OrderSummary(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      status: (json['status'] ?? 'created').toString(),
      items: itemsList,
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      currency: (json['currency'] ?? 'INR').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'Razorpay').toString(),
      receipt: json['receipt']?.toString(),
      shippingAddress: (json['shippingAddress'] is Map)
          ? OrderAddress.fromJson(
              Map<String, dynamic>.from(json['shippingAddress']),
            )
          : null,
    );
  }
}

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final ValueNotifier<List<OrderSummary>> orders =
      ValueNotifier<List<OrderSummary>>([]);

  Future<List<OrderSummary>> fetchOrders() async {
    try {
      final uri = Uri.parse('${CartService.instance.baseUrl}/orders');
      final res = await http
          .get(uri, headers: CartService.instance.defaultHeaders())
          .timeout(const Duration(seconds: 12));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = json.decode(res.body);
        final raw = (decoded is Map && decoded['orders'] is List)
            ? decoded['orders'] as List
            : [];
        final list = raw.map<OrderSummary>((e) {
          if (e is Map<String, dynamic>) return OrderSummary.fromJson(e);
          return OrderSummary.fromJson(Map<String, dynamic>.from(e));
        }).toList();
        orders.value = list;
        return list;
      }

      orders.value = [];
      return [];
    } catch (e, st) {
      debugPrint('OrderService.fetchOrders error: $e\n$st');
      orders.value = [];
      rethrow;
    }
  }

  void clear() {
    orders.value = [];
  }
}
