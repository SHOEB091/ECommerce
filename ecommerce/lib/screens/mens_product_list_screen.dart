import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class MensProductListScreen extends StatelessWidget {
  const MensProductListScreen({super.key});

  final List<Map<String, dynamic>> products = const [
    {"name": "Casual Shirt", "price": "\$45.00", "image": "assets/shirt.jpg", "rating": 4.6, "reviews": 120},
    {"name": "Denim Jacket", "price": "\$80.00", "image": "assets/tshirt.jpg", "rating": 4.7, "reviews": 98},
    {"name": "Trousers", "price": "\$55.00", "image": "assets/sample10.jpg", "rating": 4.5, "reviews": 150},
    {"name": "Sports T-Shirt", "price": "\$35.00", "image": "assets/sample9.jpg", "rating": 4.8, "reviews": 210},
    {"name": "Hoodie", "price": "\$60.00", "image": "assets/sample8.jpg", "rating": 4.9, "reviews": 321},
    {"name": "Formal Pants", "price": "\$70.00", "image": "assets/sample7.jpg", "rating": 4.3, "reviews": 102},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Men's Collection")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 15, childAspectRatio: 0.6),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(product["image"], fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                const SizedBox(height: 6),
                Text(product["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(product["price"], style: const TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text("${product["rating"]} (${product["reviews"]})"),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
