import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'all_product_screen.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 🔹 Check screen width for responsiveness
          bool isDesktop = constraints.maxWidth > 900;
          bool isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 900;

          double imageWidth = isDesktop
              ? constraints.maxWidth * 0.4 // 40% of desktop width
              : isTablet
                  ? constraints.maxWidth * 0.6
                  : double.infinity;

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000), // limit content width
              padding: const EdgeInsets.all(16),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Product Image (Left Side)
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                product["image"],
                                width: imageWidth,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 40),

                        // 🔹 Product Details (Right Side)
                        Expanded(
                          flex: 5,
                          child: _buildDetailsSection(context),
                        ),
                      ],
                    )
                  : _buildMobileView(context, imageWidth),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Mobile view layout (Column)
  Widget _buildMobileView(BuildContext context, double imageWidth) {
    return ListView(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            product["image"],
            width: imageWidth,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailsSection(context),
      ],
    );
  }

  // 🔹 Common details UI (used in both desktop & mobile)
  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product["name"],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(product["price"],
            style: const TextStyle(fontSize: 20, color: Colors.deepPurple)),
        const SizedBox(height: 16),
        const Text("Description",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const Text(
          "A stylish, high-quality product perfect for your collection. "
          "Designed with premium materials to ensure comfort and durability.",
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 24),

        // 🛒 Add to Cart button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CartScreen()));
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Add to Cart"),
        ),

        const SizedBox(height: 12),

        // 🔹 View All Products button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllProductsScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            "View All Products",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
