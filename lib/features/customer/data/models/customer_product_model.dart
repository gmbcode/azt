class CustomerProductModel {
  final String id; // Listing ID
  final String retailerId;
  final String inventoryItemId;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final int availableQty;

  CustomerProductModel({
    required this.id,
    required this.retailerId,
    required this.inventoryItemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.availableQty,
  });

  factory CustomerProductModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CustomerProductModel(
      id: id,
      retailerId: map['retailerId'] ?? '',
      inventoryItemId: map['inventoryItemId'] ?? '',
      name: map['name'] ?? 'Unknown Product',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'General',
      availableQty: (map['available_listed_qty'] as num?)?.toInt() ?? 0,
    );
  }
}