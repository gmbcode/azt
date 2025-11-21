class RetailerInventoryItemModel {
  final String id; // RTDB Key
  final String name;
  final String category;
  final double price; // Retailer's Selling Price
  final double costPrice; // Price bought from Wholesaler
  final int stockremain;
  final String description;
  final String imageUrl;
  
  // Listing Logic for RTDB
  final bool isLive; // Is it currently listed for customers?
  final String? listingId; // ID in listings_retailer
  final int listedQty; // Qty currently live

  RetailerInventoryItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.costPrice,
    required this.stockremain,
    required this.description,
    required this.imageUrl,
    this.isLive = false,
    this.listingId,
    this.listedQty = 0,
  });

  // Convert to Map for RTDB
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'costPrice': costPrice,
      'stockremain': stockremain,
      'description': description,
      'imageUrl': imageUrl,
      'isLive': isLive,
      'listingId': listingId,
      'listedQty': listedQty,
    };
  }

  // Create from RTDB Map
  factory RetailerInventoryItemModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return RetailerInventoryItemModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      stockremain: (map['stockremain'] as num?)?.toInt() ?? 0,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isLive: map['isLive'] ?? false,
      listingId: map['listingId'],
      listedQty: (map['listedQty'] as num?)?.toInt() ?? 0,
    );
  }
}