class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String image;
  final String? categoryId;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    this.categoryId,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      image: json['image'] ?? '',
      categoryId: category is Map<String, dynamic> ? category['_id'] : null,
      categoryName: category is Map<String, dynamic> ? category['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image': image,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
