class AppUser {
  final String uid;
  final String email;
  final bool emailVerified;
  final String name;  // Add this field

  AppUser({
    required this.uid,
    required this.email,
    this.emailVerified = false,
    this.name = '',  // Default to empty string
  });

  // toJson converter
  Map<String,dynamic> toJson(){
    return{
      'uid': uid,
      'email': email,
      'emailVerified': emailVerified,
      'name': name,
    };
  }

  // fromJson converter
  factory AppUser.fromJson(Map<String,dynamic> jsonUser){
    return AppUser(
      uid: jsonUser['uid'], 
      email: jsonUser['email'],
      emailVerified: jsonUser['emailVerified'] ?? false,
      name: jsonUser['name'] ?? '',
    );
  }
}