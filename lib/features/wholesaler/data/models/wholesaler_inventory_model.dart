class WholesalerInventoryItem {
  final String id; // RTDB Key
  final String name;
  final String category;
  final double price;
  final int stock;
  final int moq; // Minimum Order Quantity
  final String description;
  final String imageUrl;
  // Linking fields for Listings
  final bool isListed; 
  final String? listingId; 

  WholesalerInventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.moq,
    required this.description,
    required this.imageUrl,
    this.isListed = false,
    this.listingId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'moq': moq,
      'description': description,
      'imageUrl': imageUrl,
      'isListed': isListed,
      'listingId': listingId,
    };
  }

  factory WholesalerInventoryItem.fromMap(String id, Map<dynamic, dynamic> map) {
    return WholesalerInventoryItem(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      moq: (map['moq'] as num?)?.toInt() ?? 1,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isListed: map['isListed'] ?? false,
      listingId: map['listingId'],
    );
  }
}