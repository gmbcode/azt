// lib/models/customer_model.dart

class CustomerModel {
  final String id; // The "dummy" key
  final String email;
  final String username;
  final String usertype;
  final String address; // ** NEW FIELD ADDED **

  CustomerModel({
    required this.id,
    required this.email,
    required this.username,
    required this.usertype,
    required this.address, // ** NEW FIELD ADDED **
  });

  factory CustomerModel.fromJson(String id, Map<String, dynamic> json) {
    return CustomerModel(
      id: id,
      email: json['email'] ?? '',
      username: json['username'] ?? 'Guest',
      usertype: json['usertype'] ?? 'consumer',
      address: json['address'] ?? 'No Address', // ** NEW FIELD ADDED **
    );
  }
}