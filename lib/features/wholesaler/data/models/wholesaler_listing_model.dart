class WholesalerListing {
  final String id; // RTDB ID of the listing
  final String inventoryItemId;
  final String wholesalerId; // ** Added **
  final String name;
  final double price;
  final int availableQty;
  final String imageUrl;
  final String category; // ** Added **

  WholesalerListing({
    required this.id,
    required this.inventoryItemId,
    required this.wholesalerId,
    required this.name,
    required this.price,
    required this.availableQty,
    required this.imageUrl,
    required this.category,
  });

  factory WholesalerListing.fromMap(String id, Map<dynamic, dynamic> map) {
    return WholesalerListing(
      id: id,
      inventoryItemId: map['inventoryItemId'] ?? '',
      // Maps 'wholesalerId' from RTDB. If missing, defaults to empty string.
      wholesalerId: map['wholesalerId'] ?? '', 
      name: map['name'] ?? 'Unknown Product',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      availableQty: (map['available_listed_qty'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? 'https://placehold.co/400?text=No+Image',
      // Maps 'category' from RTDB.
      category: map['category'] ?? 'General', 
    );
  }
}