class ProductModel {
  final String id;
  final String category;
  final String description;
  final String imageUrl;
  final String name;
  final double price;
  final int stockremain;

  ProductModel({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.stockremain,
  });

  factory ProductModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return ProductModel(
      id: id,
      category: json['category'] ?? 'Uncategorized',
      description: json['description'] ?? '',
      // Check both 'imageurl' (RTDB) and 'imageUrl' (standard)
      imageUrl: json['imageurl'] ?? json['imageUrl'] ?? 'https://placehold.co/400x400/grey/white?text=No+Image',
      name: json['name'] ?? 'No Name',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockremain: (json['stockremain'] as num?)?.toInt() ?? 0,
    );
  }
}