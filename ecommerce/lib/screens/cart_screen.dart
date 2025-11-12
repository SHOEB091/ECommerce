// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _fmtPaise(int paise) {
    final rs = paise / 100.0;
    final f = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return f.format(rs);
  }

  @override
  Widget build(BuildContext context) {
    final service = CartService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: service.items,
        builder: (context, list, _) {
          if (list.isEmpty) return const Center(child: Text('Your cart is empty'));
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 0.5),
                  itemBuilder: (context, index) {
                    final c = list[index];
                    return ListTile(
                      leading: c.image != null ? Image.network(c.image!, width: 56, height: 56, fit: BoxFit.cover) : CircleAvatar(child: Text(c.title.substring(0,1))),
                      title: Text(c.title),
                      subtitle: Text('${_fmtPaise(c.priceInPaise)} • Qty: ${c.qty}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => service.updateQty(c.id, c.qty - 1)),
                          Text('${c.qty}'),
                          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => service.updateQty(c.id, c.qty + 1)),
                          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => service.remove(c.id)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(_fmtPaise(service.totalPaise as int), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ])),
                    ElevatedButton(onPressed: () {
                      // TODO: navigate to checkout/payment
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proceed to Checkout (demo)')));
                    }, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Text('Checkout')))
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
