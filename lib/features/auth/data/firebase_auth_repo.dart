import 'package:azt/features/auth/domain/entities/app_user.dart';
import 'package:azt/features/auth/domain/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


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
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      //return user
      return user;

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
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      //return user
      return user;
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
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);
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
    );
    return appUser;
  } 
  catch (e) {
    print(e);
    return null;
  }
}
}
