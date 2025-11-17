import 'package:azt/features/auth/domain/repos/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserRepo implements UserRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //save user data
  @override
  Future<void> saveUserData(String uid, String email, String username) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'roleAllot': null,     //role initialise
      });
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }
  
  //get username
  @override
  Future<String> getUserUsername(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['username'] ?? '';
    } catch (e) {
      throw Exception('Failed to get username: $e');
    }
  }
  
  //get userdata
  @override
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }
  
  //update username
  @override
  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'username': newUsername,
      });
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }
  
  //delete userdata 
  @override
  Future<void> deleteUserData(String uid) async {
    try {
      //delete from users collection
      await _firestore.collection('users').doc(uid).delete();
      
      //delete rom role collections if exists
      final userData = await getUserData(uid);
      final role = userData?['roleAllot'];
      
      if (role != null) {
        String collection = '';
        if (role == 'customer') {
          collection = 'customers';
        }
        else if (role == 'retailer') {
          collection = 'retailers';
        }
        else if (role == 'wholesaler') {
          collection = 'wholesalers';
        }
        

        //delete data from collection
        if (collection.isNotEmpty) {
          await _firestore.collection(collection).doc(uid).delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  //check if user exists
  @override
  Future<bool> checkIfUserExists(String uid) async{
    try {
      DocumentSnapshot s = await _firestore.collection('users').doc(uid).get();
      return s.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  //update/set user role in users collection
  @override
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'roleAllot': role,
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  //get user role data from users collection
  @override
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['roleAllot'];
    } catch (e) {
      throw Exception('Failed to get user role: $e');
    }
  }

  //save role specific data in particular collection
  @override
  Future<void> saveRoleData(String uid, String role, String address, String pincode, {String? businessName}) async {
    try {
      String collection = '';
      if (role == 'customer') {
        collection = 'customers';
      }
      else if (role == 'retailer'){
        collection = 'retailers';
      }
      else if (role == 'wholesaler'){
        collection = 'wholesalers';
      }
      
      if (collection.isEmpty) {
        throw Exception('Invalid role: $role');
      }
      
      final Map<String, dynamic> data = {
        'uid': uid,
        'address': address,
        'pincode': pincode,
      };
      
      if (businessName != null && (role == 'retailer' || role == 'wholesaler')) {
        data['businessName'] = businessName;
      }
      
      await _firestore.collection(collection).doc(uid).set(data);
    } catch (e) {
      throw Exception('Failed to save role data: $e');
    }
  }

  //get role specific data from respective collection
  @override
  Future<Map<String, dynamic>?> getRoleData(String uid, String role) async {
    try {
      String collection = '';
      if (role == 'customer') {
        collection = 'customers';
      }
      else if (role == 'retailer'){
        collection = 'retailers';
      }
      else if (role == 'wholesaler'){
        collection = 'wholesalers';
      }
      
      if (collection.isEmpty) return null;
      
      final doc = await _firestore.collection(collection).doc(uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get role data: $e');
    }
  }

}