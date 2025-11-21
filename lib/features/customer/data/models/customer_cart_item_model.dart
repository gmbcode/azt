class CustomerCartItemModel {
  final String productId;
  final String retailerId;
  final String name;
  final double price;
  final String imageUrl;
  final int qty;

  CustomerCartItemModel({
    required this.productId,
    required this.retailerId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.qty,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'retailerId': retailerId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'qty': qty,
    };
  }
  
  // Create copy with new quantity
  CustomerCartItemModel copyWith({int? qty}) {
    return CustomerCartItemModel(
      productId: productId,
      retailerId: retailerId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      qty: qty ?? this.qty,
    );
  }
}