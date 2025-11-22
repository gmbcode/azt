class WholesalerInventoryItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;      // Unlisted Reserve
  final int listedQty;  // Added: Public Listed Stock
  final int moq;
  final String description;
  final String imageUrl;
  final bool isListed;
  final String? listingId;

  WholesalerInventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.listedQty = 0, // Default 0
    required this.moq,
    required this.description,
    required this.imageUrl,
    this.isListed = false,
    this.listingId,
  });

  factory WholesalerInventoryItem.fromMap(String id, Map<dynamic, dynamic> map) {
    return WholesalerInventoryItem(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      listedQty: (map['listedQty'] as num?)?.toInt() ?? 0, // Map this
      moq: (map['moq'] as num?)?.toInt() ?? 1,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isListed: map['isListed'] ?? false,
      listingId: map['listingId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'listedQty': listedQty, // Save this
      'moq': moq,
      'description': description,
      'imageUrl': imageUrl,
      'isListed': isListed,
      'listingId': listingId,
    };
  }
}