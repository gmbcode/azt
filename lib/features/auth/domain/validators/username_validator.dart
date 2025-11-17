class UsernameValidator {
  static String? validate(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (username.length > 20) {
      return 'Username must be no more than 20 characters';
    }
    
    //valid username check
    final validUsername = RegExp(r'^[a-zA-Z0-9_ ]+$');
    if (!validUsername.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null; //returns null on valid username
  }
  
  static bool isValid(String? username) {
    return validate(username) == null;          //for valid null is returned, hence for valid, this bool is true
  }
}