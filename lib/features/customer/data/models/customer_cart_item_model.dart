class CustomerCartItemModel {
  final String productId;
  final String retailerId;
  final String inventoryItemId;
  final String name;
  final double price;
  final String imageUrl;
  final int qty;

  CustomerCartItemModel({
    required this.productId,
    required this.retailerId,
    required this.inventoryItemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.qty,
  });

  // --- ADD THIS FACTORY ---
  factory CustomerCartItemModel.fromMap(Map<dynamic, dynamic> map) {
    return CustomerCartItemModel(
      productId: map['id']?.toString() ?? '',
      retailerId: map['retailerId']?.toString() ?? '', // Ensure we save this key
      inventoryItemId: map['inventoryItemId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown',
      price: double.tryParse(map['price'].toString()) ?? 0.0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      qty: int.tryParse(map['qty'].toString()) ?? 0,
    );
  }

  CustomerCartItemModel copyWith({int? qty}) {
    return CustomerCartItemModel(
      productId: productId,
      retailerId: retailerId,
      inventoryItemId: inventoryItemId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': productId,
      'retailerId': retailerId, // Important: Add this to the map so we can retrieve it later
      'inventoryItemId': inventoryItemId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'qty': qty,
    };
  }
}