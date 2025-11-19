// lib/models/inventory_item_model.dart

class InventoryItemModel {
  final String id;
  String name;
  String category;
  double price;
  int stockRemain;
  int stocksold;
  String description;
  String imageUrl;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stockRemain,
    required this.stocksold,
    required this.description,
    required this.imageUrl,
  });

  factory InventoryItemModel.fromJson(String id, Map<String, dynamic> json) {
    return InventoryItemModel(
      id: id,
      name: json['name'] ?? 'Unknown Product',
      category: json['category'] ?? 'General',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockRemain: json['stockremain'] ?? 0,
      stocksold: json['stocksold'] ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}