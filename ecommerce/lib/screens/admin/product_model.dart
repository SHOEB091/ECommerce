class Product {
final String id;
final String name;
final String description;
final double price;
final String imageUrl;
final String category;
final int stock;


Product({
required this.id,
required this.name,
required this.description,
required this.price,
required this.imageUrl,
required this.category,
required this.stock,
});


factory Product.fromJson(Map<String, dynamic> json) {
return Product(
id: json['_id'],
name: json['name'],
description: json['description'],
price: (json['price'] as num).toDouble(),
imageUrl: json['image'] ?? '',
category: json['category'] ?? '',
stock: json['stock'] ?? 0,
);
}
}