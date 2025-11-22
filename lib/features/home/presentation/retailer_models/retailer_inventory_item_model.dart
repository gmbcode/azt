class RetailerInventoryItemModel {
  final String id;
  final String name;
  final String category;
  final double price; // Selling Price
  final double costPrice; // Cost Price
  final int stockremain; // UNLISTED Reserve Stock
  final int listedQty;   // LISTED Public Stock
  final String description;
  final String imageUrl;
  final bool isLive;
  final String? listingId;

  RetailerInventoryItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.costPrice,
    required this.stockremain,
    this.listedQty = 0,
    required this.description,
    required this.imageUrl,
    this.isLive = false,
    this.listingId,
  });

  factory RetailerInventoryItemModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return RetailerInventoryItemModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      // These two fields are critical for the split logic
      stockremain: (map['stockremain'] as num?)?.toInt() ?? 0,
      listedQty: (map['listedQty'] as num?)?.toInt() ?? 0,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isLive: map['isLive'] ?? false,
      listingId: map['listingId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'costPrice': costPrice,
      'stockremain': stockremain,
      'listedQty': listedQty,
      'description': description,
      'imageUrl': imageUrl,
      'isLive': isLive,
      'listingId': listingId,
    };
  }
}