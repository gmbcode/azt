class WholesalerListing {
  final String id; // RTDB ID
  final String inventoryItemId;
  final String wholesalerId;
  final String name;
  final double price;
  final int availableQty;
  final String imageUrl;
  final String category;
  final int moq; // FIXED: Added MOQ

  WholesalerListing({
    required this.id,
    required this.inventoryItemId,
    required this.wholesalerId,
    required this.name,
    required this.price,
    required this.availableQty,
    required this.imageUrl,
    required this.category,
    this.moq = 1, // Default to 1
  });

  factory WholesalerListing.fromMap(String id, Map<dynamic, dynamic> map) {
    return WholesalerListing(
      id: id,
      inventoryItemId: map['inventoryItemId'] ?? '',
      wholesalerId: map['wholesalerId'] ?? '', 
      name: map['name'] ?? 'Unknown Product',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      availableQty: (map['available_listed_qty'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? 'https://placehold.co/400?text=No+Image',
      category: map['category'] ?? 'General',
      moq: (map['moq'] as num?)?.toInt() ?? 1, // FIXED: Map MOQ
    );
  }
}