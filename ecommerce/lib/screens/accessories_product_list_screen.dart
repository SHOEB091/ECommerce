import 'package:flutter/material.dart';

class AccessoriesProductListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
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
    {
      "name": "Sunglasses",
      "price": "\$40.00",
      "image": "assets/chasma.jpg",
      "rating": 4.5,
      "reviews": 183
    },
    {
      "name": "Backpack",
      "price": "\$55.00",
      "image": "assets/bag.jpg",
      "rating": 4.7,
      "reviews": 129
    },
    {
      "name": "Cap",
      "price": "\$25.00",
      "image": "assets/cap.jpg",
      "rating": 4.4,
      "reviews": 92
    },
    {
      "name": "Leather Belt",
      "price": "\$35.00",
      "image": "assets/bag.jpg",
      "rating": 4.5,
      "reviews": 115
    },
    {
      "name": "Travel Bag",
      "price": "\$85.00",
      "image": "assets/bag.jpg",
      "rating": 4.6,
      "reviews": 133
    },
    {
      "name": "Wireless Earbuds",
      "price": "\$99.00",
      "image": "assets/cap.jpg",
      "rating": 4.9,
      "reviews": 211
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        title: const Text(
          "Accessories",
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
            const Text(
              "Found 78 Results",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
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
                  return Column(
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
