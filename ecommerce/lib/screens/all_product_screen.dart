import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class AllProductsScreen extends StatelessWidget {
  AllProductsScreen({super.key});

  final List<Map<String, dynamic>> allProducts = [
    // --- Men's ---
    {
      "name": "Casual Shirt",
      "price": "\$45.00",
      "image": "assets/shirt.jpg",
      "rating": 4.5,
      "reviews": 120
    },
    {
      "name": "Denim Jacket",
      "price": "\$65.00",
      "image": "assets/sample10.jpg",
      "rating": 4.7,
      "reviews": 98
    },

    // --- Women's ---
    {
      "name": "Linen Dress",
      "price": "\$52.00",
      "image": "assets/sample5.jpg",
      "rating": 4.5,
      "reviews": 134
    },
    {
      "name": "Maxi Dress",
      "price": "\$68.00",
      "image": "assets/sample7.jpg",
      "rating": 4.6,
      "reviews": 146
    },

    // --- Accessories ---
    {
      "name": "Leather Wallet",
      "price": "\$30.00",
      "image": "assets/purse.jpg",
      "rating": 4.8,
      "reviews": 145
    },
    {
      "name": "Analog Watch",
      "price": "\$75.00",
      "image": "assets/watch.jpg",
      "rating": 4.6,
      "reviews": 201
    },

    // --- More ---
    {
      "name": "Perfume",
      "price": "\$40.00",
      "image": "assets/perfume.jpg",
      "rating": 4.3,
      "reviews": 132
    },
    {
      "name": "Gift Box",
      "price": "\$50.00",
      "image": "assets/giftbox.jpg",
      "rating": 4.4,
      "reviews": 158
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Products",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.filter_list_rounded, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Found ${allProducts.length} Results",
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.58, // slightly taller cards
                  ),
                  itemCount: allProducts.length,
                  itemBuilder: (context, index) {
                    final product = allProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      product["image"],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                  const Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.favorite_border,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product["price"],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 3),
                                      Text("${product["rating"]}",
                                          style:
                                              const TextStyle(fontSize: 13)),
                                      const SizedBox(width: 3),
                                      Text("(${product["reviews"]})",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
