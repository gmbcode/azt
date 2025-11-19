class Retailer {
  final String uid;
  final String address;
  final String businessName;
  final String pincode;

  Retailer({
    required this.uid,
    required this.address,
    required this.businessName,
    required this.pincode,
  });

  factory Retailer.fromJson(Map<String, dynamic> json) {
    return Retailer(
      uid: json['uid'] ?? '',
      address: json['address'] ?? '',
      businessName: json['businessName'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'address': address,
      'businessName': businessName,
      'pincode': pincode,
    };
  }
}
