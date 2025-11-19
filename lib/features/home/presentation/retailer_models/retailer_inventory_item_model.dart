class RetailerInventoryItemModel {
  final String id;
  final String category;
  final String description;
  final String imageUrl;
  final String name;
  final double price;
  final int stockremain;
  final int stocksold;

  RetailerInventoryItemModel({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.stockremain,
    required this.stocksold,
  });

  factory RetailerInventoryItemModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return RetailerInventoryItemModel(
      id: id,
      category: json['category'] ?? 'Uncategorized',
      description: json['description'] ?? '',
      // Check both 'imageurl' (RTDB) and 'imageUrl'
      imageUrl: json['imageurl'] ?? json['imageUrl'] ?? 'https://placehold.co/400x400/grey/white?text=No+Image',
      name: json['name'] ?? 'No Name',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockremain: (json['stockremain'] as num?)?.toInt() ?? 0,
      stocksold: (json['stocksold'] as num?)?.toInt() ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'imageurl': imageUrl, // writing back as imageurl to match schema
      'name': name,
      'price': price,
      'stockremain': stockremain,
      'stocksold': stocksold,
    };
  }
}