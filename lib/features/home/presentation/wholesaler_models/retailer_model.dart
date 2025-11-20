// lib/models/retailer_model.dart

class RetailerModel {
  final String address;
  final String businessName;
  final String userType;
  final String id; 
  final Map<String, dynamic> inventory; // The type Dart is complaining about
  final bool isNewSignup; 

  RetailerModel({
    required this.address,
    required this.businessName,
    required this.userType,
    required this.id,
    required this.inventory,
    required this.isNewSignup,
  });

  factory RetailerModel.fromJson(String id, Map<String, dynamic> json) {
    
    // 💡 The most likely source of the error is here. 
    // We must ensure 'inventory' is cast correctly before assignment.
    final rawInventory = json['inventory'];
    Map<String, dynamic> safeInventory;

    if (rawInventory is Map) {
      // Use .cast() to explicitly enforce the Map<String, dynamic> type on the contents
      safeInventory = rawInventory.cast<String, dynamic>();
    } else {
      safeInventory = {};
    }

    return RetailerModel(
      address: json['address'] ?? 'No Address',
      businessName: json['businessname'] ?? 'No Business Name',
      userType: json['usertype'] ?? 'retailer',
      inventory: safeInventory, // Use the safely cast map
      id: id,
      isNewSignup: json['businessname']?.toString().toLowerCase().contains('store') ?? false,
    );
  }
}