import 'package:azt/features/auth/domain/entities/app_user.dart';
import 'package:azt/features/auth/domain/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthRepo implements AuthRepo{
  //firebase access
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  //LOGIN with email,pass 
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try{
      //try to sign in
      UserCredential userCredential = await firebaseAuth
      .signInWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email,emailVerified: userCredential.user!.emailVerified);

      //return user
      return user;

    } on FirebaseAuthException catch (e){
        switch (e.code) {
      case 'invalid-email':
        throw Exception('The email address is not valid.');
      case 'user-disabled':
        throw Exception('This user has been disabled.');
      case 'user-not-found':
        throw Exception('No user found for that email.');
      case 'wrong-password':
        throw Exception('Wrong password provided for that user.');
      case 'too-many-requests':
        throw Exception('Too many attempts. Try again later.');
      case 'network-request-failed':
        throw Exception('Please connect to internet and try again later');
      default:
        throw Exception('Login failed. ${e.message ?? 'Please try again.'}');
    }
    }
    //catch errors
    catch(e){
      throw Exception('Login failed: $e');
    }
  }

  //REGISTER
  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async {
    try{

      //attempt signup
      UserCredential userCredential = await firebaseAuth
      .createUserWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email,emailVerified: userCredential.user!.emailVerified);

      //return user
      return user;
    } on FirebaseAuthException catch(e){
      switch (e.code) {
      case 'invalid-email':
        throw Exception('The email address is not valid.');
      case 'email-already-in-use':
        throw Exception('Email address is already in use');
      case 'too-many-requests':
        throw Exception('Too many attempts. Try again later.');
      case 'network-request-failed':
        throw Exception('Please connect to internet and try again later');
      default:
        throw Exception('Registration failed. ${e.message ?? 'Please try again.'}');
    }
    }
    catch(e){
      throw Exception('Registration failed: $e');
    }
  }
  
  //DELETE ACC
  @override
  Future<void> deleteAccount() async {
    try{

      //get current user
      final user = firebaseAuth.currentUser;

      //check for null
      if (user==null) throw Exception('No user found..');

      //try to delete acc
      await user.delete();

      //logout
      await logout();
    }
    catch(e){
      throw Exception("Failed to delete user.. : $e");
    }
  }
  

  // GET CURRENT USER
  @override
  Future<AppUser?> getCurrentUser() async{
    //get current logged in user from db
    final firebaseUser = firebaseAuth.currentUser;
    //no logged in user
    if (firebaseUser == null) return null;

    //logged in user
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!,emailVerified: firebaseUser.emailVerified);
  }
  

  //LOGOUT
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();

  }
  

  //RESET PASSWORD
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try{
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent!";
    }
    catch(e){
      return "An error occured: $e";
    }
  }
  
  @override
  Future<AppUser?> signInWithGoogle() async {
  try {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    googleProvider.addScope('email');
    googleProvider.addScope('profile');
    
    UserCredential userCredential;
    
    if (!kIsWeb) {
      // Mobile platforms
      userCredential = await FirebaseAuth.instance.signInWithProvider(googleProvider);
    } else {
      // Web platform - use signInWithPopup instead
      userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
    }
    
    // user cancelled sign-in
    if (userCredential.user == null) return null;
    
    // firebase user
    final firebaseUser = userCredential.user!;
    
    AppUser appUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      emailVerified: firebaseUser.emailVerified, //Should be set to true by default after gsignin
    );
    return appUser;
  } 
  catch (e) {
    print(e);
    return null;
  }
}
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }
  Future<AppUser?> reloadUser() async {
  try {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    
    // Reload user data from Firebase
    await user.reload();
    
    // Get the updated user
    final updatedUser = firebaseAuth.currentUser;
    if (updatedUser == null) return null;
    
    return AppUser(
      uid: updatedUser.uid,
      email: updatedUser.email!,
      emailVerified: updatedUser.emailVerified,
    );
  } catch (e) {
    throw Exception('Failed to reload user: $e');
  }
}
}
