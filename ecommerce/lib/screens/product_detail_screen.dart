// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'package:ecommerce/screens/admin/product_model.dart';

/// Main product details screen (used by new code)
class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 80, color: Colors.grey)))
                  : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey))),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("₹${product.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text(product.description.isNotEmpty ? product.description : "No description available.", style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 24),
          Row(children: [
            const Icon(Icons.inventory_2_outlined, color: Colors.grey),
            const SizedBox(width: 8),
            Text("In stock: ${product.stock}", style: const TextStyle(color: Colors.grey)),
          ]),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                final ok = await CartService.instance.addItem(product.id, qty: 1);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Added "${product.name}" to cart' : 'Failed to add to cart')));
              },
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: const Text("Add to Cart", style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

/// Compatibility wrapper for files that reference `ProductDetailScreen` (singular)
/// Many of your existing files reference ProductDetailScreen; this wrapper forwards to ProductDetailsScreen.
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) => ProductDetailsScreen(product: product);
}
