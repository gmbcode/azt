class AppUser {
  final String uid;
  final String email;
  final bool emailVerified;
  final String name;
  final String? roleAllot;

  AppUser({
    required this.uid,
    required this.email,
    this.emailVerified = false,
    this.name = '', 
    this.roleAllot,
  });

  // toJson converter
  Map<String,dynamic> toJson(){
    return{
      'uid': uid,
      'email': email,
      'emailVerified': emailVerified,
      'name': name,
      'rollAllot':roleAllot,
    };
  }

  // fromJson converter
  factory AppUser.fromJson(Map<String,dynamic> jsonUser){
    return AppUser(
      uid: jsonUser['uid'], 
      email: jsonUser['email'],
      emailVerified: jsonUser['emailVerified'] ?? false,
      name: jsonUser['name'] ?? '',
      roleAllot: jsonUser['rollAllot'],
    );
  }
}