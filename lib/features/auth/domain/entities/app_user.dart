class AppUser {
  final String uid;
  final String email;

  AppUser({
    required this.uid,
    required this.email,
  });

  //app user to json converter
  Map<String,dynamic> toJson(){
    return{
      'uid':uid,
      'email':email,
    };
  }

  //json to app user converter
  factory AppUser.fromJson(Map<String,dynamic> jsonUser){
      return AppUser(
        uid: jsonUser['uid'], 
        email:jsonUser['email'],
      );
  }
}