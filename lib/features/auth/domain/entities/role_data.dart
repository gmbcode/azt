class RoleData {

  final String uid;
  final String address;
  final String pincode;
  final String? businessName;

  RoleData({
    required this.uid, 
    required this.address, 
    required this.pincode, 
    this.businessName
    }
  );        

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = {
      'uid':uid,
      'address':address,
      'pincode':pincode,
    };

    if (businessName != null){
      data['businessName']= businessName;
    }

    return data;
  }
  factory RoleData.fromJson(Map<String, dynamic> json) {
    return RoleData(
      uid: json['uid'],
      address: json['address'],
      pincode: json['pincode'],
      businessName: json['businessName'],
    );
  }
}