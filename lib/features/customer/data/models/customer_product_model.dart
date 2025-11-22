class CustomerProductModel {
  final String id;
  final String retailerId;
  final String inventoryItemId; 
  final String name;
  final double price;
  final int availableQty;
  final String imageUrl;
  final String category;

  CustomerProductModel({
    required this.id,
    required this.retailerId,
    required this.inventoryItemId,
    required this.name,
    required this.price,
    required this.availableQty,
    required this.imageUrl,
    required this.category,
  });

  factory CustomerProductModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CustomerProductModel(
      id: id,
      retailerId: map['retailerId']?.toString() ?? '',
      inventoryItemId: map['inventoryItemId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Product',
      
      // ROBUST PARSING: Handle String or Number for Price
      price: _parseDouble(map['price']),
      
      // ROBUST PARSING: Handle String or Number for Qty
      availableQty: _parseInt(map['available_listed_qty']),
      
      imageUrl: map['imageUrl']?.toString() ?? 'https://placehold.co/400?text=No+Image',
      category: map['category']?.toString() ?? 'General',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}