class WholesalerListing {
  final String id; // RTDB ID of the listing
  final String inventoryItemId;
  final String name;
  final double price;
  final int availableQty;
  final String imageUrl;

  WholesalerListing({
    required this.id,
    required this.inventoryItemId,
    required this.name,
    required this.price,
    required this.availableQty,
    required this.imageUrl,
  });

  factory WholesalerListing.fromMap(String id, Map<dynamic, dynamic> map) {
    return WholesalerListing(
      id: id,
      inventoryItemId: map['inventoryItemId'] ?? '',
      name: map['name'] ?? 'Unknown',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      availableQty: (map['available_listed_qty'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}