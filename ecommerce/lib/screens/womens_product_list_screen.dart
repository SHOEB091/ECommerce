import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class WomenProductListScreen extends StatelessWidget {
  const WomenProductListScreen({super.key});

  final List<Map<String, dynamic>> products = const [
    {
      "name": "Linen Dress",
      "price": "\$52.00",
      "image": "assets/sample5.jpg",
      "rating": 4.5,
      "reviews": 134
    },
    {
      "name": "Fitted Waist Dress",
      "price": "\$47.99",
      "image": "assets/sample6.jpg",
      "rating": 4.2,
      "reviews": 119
    },
    {
      "name": "Maxi Dress",
      "price": "\$68.00",
      "image": "assets/sample7.jpg",
      "rating": 4.6,
      "reviews": 146
    },
    {
      "name": "Front Tie Mini Dress",
      "price": "\$59.00",
      "image": "assets/sample8.jpg",
      "rating": 4.0,
      "reviews": 118
    },
    {
      "name": "Ohara Dress",
      "price": "\$85.00",
      "image": "assets/sample9.jpg",
      "rating": 4.7,
      "reviews": 203
    },
    {
      "name": "Tie Back Mini Dress",
      "price": "\$67.00",
      "image": "assets/sample_img4.jpg",
      "rating": 4.3,
      "reviews": 179
    },
    {
      "name": "Leaves Green Dress",
      "price": "\$64.00",
      "image": "assets/sample_img3.jpg",
      "rating": 4.8,
      "reviews": 213
    },
    {
      "name": "Off Shoulder Dress",
      "price": "\$78.99",
      "image": "assets/sample_image1.jpg",
      "rating": 4.5,
      "reviews": 191
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
          "Dresses",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Found ${products.length} Results",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.6,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                product["image"],
                                fit: BoxFit.cover,
                                height: 210,
                                width: double.infinity,
                              ),
                            ),
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.favorite_border,
                                    color: Colors.black, size: 18),
                              ),
                            ),
                          ],
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
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 3),
                            Text("${product["rating"]}",
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 3),
                            Text("(${product["reviews"]})",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
