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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Men's Collection",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2; // mobile default

          if (constraints.maxWidth > 1200) {
            crossAxisCount = 5; // desktop
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 4; // large tablet
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3; // small tablet
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 20,
                crossAxisSpacing: 15,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                product["image"],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product["name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product["price"],
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "${product["rating"]}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "(${product["reviews"]})",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
