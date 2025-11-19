class RetailerInventoryItemModel {
  final String id; // The "dummy" key
  final String category;
  final String description;
  final String imageUrl;
  final String name;
  final double price; // Retailer's OWN price
  final int stockremain;
  final int stocksold;

  RetailerInventoryItemModel({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.stockremain,
    required this.stocksold,
  });

  factory RetailerInventoryItemModel.fromJson(String id, Map<String, dynamic> json) {
    return RetailerInventoryItemModel(
      id: id,
      category: json['category'] ?? 'Uncategorized',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? 'No Name',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockremain: (json['stockremain'] as num?)?.toInt() ?? 0,
      stocksold: (json['stocksold'] as num?)?.toInt() ?? 0,
    );
  }
}