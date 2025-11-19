class Product {
  final String id;
  final String category;
  final String description;
  final String imageUrl;
  final String name;
  final double price;
  final int productId;

  Product({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.productId,
  });

  factory Product.fromJson(String id, Map<String, dynamic> json) {
    return Product(
      id: id,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageurl'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      productId: (json['productid'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'imageurl': imageUrl,
      'name': name,
      'price': price,
      'productid': productId,
    };
  }
}
