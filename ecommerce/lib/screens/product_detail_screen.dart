import 'package:flutter/material.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product["name"]),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(product["image"]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(product["name"], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(product["price"], style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
          const Text("A stylish, high-quality product perfect for your collection."),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}
