// lib/models/product_model.dart

// (This is the class you provided, now in its own file)
class ProductModel {
  final String id; // The "dummy" key
  final String category;
  final String description;
  final String imageUrl;
  final String name;
  final double price; // Wholesale price
  final int stockremain;
  // 'stocksold' is not needed for browsing, but could be added

  ProductModel({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.stockremain,
  });

  factory ProductModel.fromJson(String id, Map<String, dynamic> json) {
    return ProductModel(
      id: id,
      category: json['category'] ?? 'Uncategorized',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? 'No Name',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockremain: (json['stockremain'] as num?)?.toInt() ?? 0,
    );
  }
}