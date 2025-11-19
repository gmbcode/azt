abstract class UserRepo {
  Future<void> saveUserData(String uid, String email, String username);
  Future<String> getUserUsername(String uid);
  Future<Map<String, dynamic>?> getUserData(String uid);
  Future<void> updateUsername(String uid, String newUsername);
  Future<void> deleteUserData(String uid);
  Future<bool> checkIfUserExists(String uid);

  //role management
  Future<void> updateUserRole(String uid, String role);
  Future<String?> getUserRole(String uid);
  Future<void> saveRoleData(String uid, String role, String address, String pincode, {String? businessName});
  Future<Map<String, dynamic>?> getRoleData(String uid, String role);
}