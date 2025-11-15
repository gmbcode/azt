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
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }
  @override
  Future<bool> checkIfUserExists(String uid) async{
    try {
      DocumentSnapshot s = await _firestore.collection('users').doc(uid).get();
      return s.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }
}