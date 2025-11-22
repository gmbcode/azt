class WholesalerListing {
  final String id; // RTDB ID
  final String inventoryItemId;
  final String wholesalerId;
  final String name;
  final double price;
  final int availableQty;
  final String imageUrl;
  final String category;
  final int moq;
  final String wholesalerName; // Added Field

  WholesalerListing({
    required this.id,
    required this.inventoryItemId,
    required this.wholesalerId,
    required this.name,
    required this.price,
    required this.availableQty,
    required this.imageUrl,
    required this.category,
    this.moq = 1,
    required this.wholesalerName, // Required
  });

  factory WholesalerListing.fromMap(String id, Map<dynamic, dynamic> map) {
    return WholesalerListing(
      id: id,
      inventoryItemId: map['inventoryItemId']?.toString() ?? '',
      wholesalerId: map['wholesalerId']?.toString() ?? '', 
      name: map['name']?.toString() ?? 'Unknown Product',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      availableQty: (map['available_listed_qty'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl']?.toString() ?? 'https://placehold.co/400?text=No+Image',
      category: map['category']?.toString() ?? 'General',
      moq: (map['moq'] as num?)?.toInt() ?? 1,
      // Safe fallback: defaults to 'Verified Seller' if name is missing/null
      wholesalerName: map['wholesalerName']?.toString() ?? 'Verified Seller', 
    );
  }
}