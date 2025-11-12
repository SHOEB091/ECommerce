import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class MoreProductListScreen extends StatelessWidget {
  const MoreProductListScreen({super.key});

  final List<Map<String, dynamic>> moreProducts = const [
    {"name": "Perfume", "price": "\$55.00", "image": "assets/perfume.jpg", "rating": 4.7, "reviews": 98},
    {"name": "Cosmetics Kit", "price": "\$65.00", "image": "assets/makeup.jpg", "rating": 4.8, "reviews": 112},
    {"name": "Gift Box", "price": "\$45.00", "image": "assets/giftbox.jpg", "rating": 4.6, "reviews": 75},
    {"name": "Belt", "price": "\$30.00", "image": "assets/belt.jpg", "rating": 4.5, "reviews": 81},
    {"name": "Towel Set", "price": "\$40.00", "image": "assets/towel.jpg", "rating": 4.4, "reviews": 69},
    {"name": "Keychain", "price": "\$15.00", "image": "assets/keychain.jpg", "rating": 4.3, "reviews": 59},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "More Items",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 🔹 Responsive logic based on available width
          int crossAxisCount = 2;
          double aspectRatio = 0.6;

          if (constraints.maxWidth >= 1200) {
            // Desktop
            crossAxisCount = 5;
            aspectRatio = 0.8;
          } else if (constraints.maxWidth >= 800) {
            // Tablet
            crossAxisCount = 3;
            aspectRatio = 0.7;
          } else if (constraints.maxWidth >= 600) {
            // Large phone
            crossAxisCount = 2;
            aspectRatio = 0.7;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Found ${moreProducts.length} Results",
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    itemCount: moreProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 15,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final product = moreProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                const SizedBox(height: 6),
                                Text(
                                  product["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product["price"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    Text(
                                      "${product["rating"]}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "(${product["reviews"]})",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
