class WholesalerViewRetailerModel {
  final String uid;
  final String businessName;
  final String address;
  final String pincode;
  final bool isNewSignup; // You can add logic for this later based on creation time

  WholesalerViewRetailerModel({
    required this.uid,
    required this.businessName,
    required this.address,
    required this.pincode,
    this.isNewSignup = false, 
  });

  factory WholesalerViewRetailerModel.fromMap(Map<String, dynamic> map) {
    return WholesalerViewRetailerModel(
      uid: map['uid'] ?? '',
      businessName: map['businessName'] ?? 'Unknown Business',
      address: map['address'] ?? 'No Address',
      pincode: map['pincode'] ?? '',
    );
  }
}