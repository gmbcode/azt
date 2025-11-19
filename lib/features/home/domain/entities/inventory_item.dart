class InventoryItem {
  final String id;
  final String category;
  final String description;
  final String imageUrl;
  final String name;
  final double price;
  final int stockremain;
  final int stocksold;

  InventoryItem({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.stockremain,
    required this.stocksold,
  });

  factory InventoryItem.fromJson(String id, Map<String, dynamic> json) {
    return InventoryItem(
      id: id,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockremain: (json['stockremain'] as num?)?.toInt() ?? 0,
      stocksold: (json['stocksold'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'name': name,
      'price': price,
      'stockremain': stockremain,
      'stocksold': stocksold,
    };
  }
}
