class Customer {
  final String id;
  final String address;
  final String emailId;
  final int customerId;
  final int pincode;

  Customer({
    required this.id,
    required this.address,
    required this.emailId,
    required this.customerId,
    required this.pincode,
  });

  factory Customer.fromJson(String id, Map<String, dynamic> json) {
    return Customer(
      id: id,
      address: json['address'] ?? '',
      emailId: json['emailid'] ?? '',
      customerId: (json['customerid'] as num?)?.toInt() ?? 0,
      pincode: (json['pincode'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'emailid': emailId,
      'customerid': customerId,
      'pincode': pincode,
    };
  }
}
