//FOR STATE MANAGEMENT

import 'package:azt/features/auth/domain/entities/app_user.dart';
import 'package:azt/features/auth/domain/repos/auth_repo.dart';
import 'package:azt/features/auth/domain/repos/user_repo.dart';
import 'package:azt/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
class AuthCubit extends Cubit<AuthState>{
  final AuthRepo authRepo;
  final UserRepo userRepo;
  final logger = Logger();
  AppUser? _currentUser;
  String? _pendingUserName;
  AuthCubit({required this.authRepo,required this.userRepo}) : super(AuthInitial());

  //get current user
  AppUser? get currentUser => _currentUser;

  //check if user is authenticated
  void checkAuth() async{
    //loading..
    emit(AuthLoading());

    //get current user
    final AppUser? user = await authRepo.getCurrentUser();

    if (user!= null){
      _currentUser = user;
        if (user.emailVerified){
          bool status = await userRepo.checkIfUserExists(user.uid);
          logger.d("Current status is $status\n from checkAuth()");
          if(!status){//If user does not exist on CFS then create user
            userRepo.saveUserData(
            user.uid,
            user.email,
            user.name,
            );
          }

          //check role selection
          final role = await userRepo.getUserRole(user.uid);
          logger.d("User Role: $role");

          //USER HAS NOT SELECTED ROLE
          if (role == null){
            emit(RoleNotSelected(user));
          }
          //user has taken a role and is authenticated
          else{
            final updatedUser = AppUser(
              uid: user.uid,
              email: user.email,
              emailVerified: user.emailVerified,
              name: user.name,
              roleAllot: role,
            );
            _currentUser = updatedUser;
            emit(Authenticated(updatedUser));
          }
        }

        else{
          emit(EmailNotVerified(user));
        }

    } else{
      emit(Unauthenticated());
    }
  }

  //login with email + password
  Future<void> login(String email, String pw) async {
    try{
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);
      
      if (user != null){
        _currentUser = user;
          if(user.emailVerified){
            
            //check role selection
            final role = await userRepo.getUserRole(user.uid);

            if (role==null || role.isEmpty){
              emit(RoleNotSelected(user));       //roll not selected
            } else{
              final updatedUser = AppUser(
                uid: user.uid,
                email: user.email,
                emailVerified: user.emailVerified,
                name: user.name,
                roleAllot: role,
              );
              _currentUser = updatedUser;
              emit(Authenticated(updatedUser));
            }
          }

          else{
            emit(EmailNotVerified(user));
          }

      } else{
        emit(Unauthenticated());
      }
    } catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //register with email + pw
  Future<void> register(String name, String email, String pw) async{
    try{
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);
      authRepo.sendEmailVerification();
      if (user != null){
        _currentUser = user;
        _pendingUserName = name;
        if(user.emailVerified){
        emit(Authenticated(user));
        }
        else{
          emit(EmailNotVerified(user));
        }
      } else{
        emit(Unauthenticated());
      }
    }
    catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //logout
  Future<void> logout() async{
    emit(AuthLoading());
    await authRepo.logout();
    emit(Unauthenticated());
  }

  //forgot password
  Future<String> forgotPassword(String email) async {
    try{
      final message = await authRepo.sendPasswordResetEmail(email);
      return message;
    }
    catch (e) {
      return e.toString();
    }
  }

  //delete account
  Future<void> deleteAccount() async{
    try{
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unauthenticated());
    }
    catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //google sign in
  Future<void> signInWithGoogle() async{
    try{
      emit(AuthLoading());
      final user = await authRepo.signInWithGoogle();

      if (user != null){
        _currentUser = user;
        final role = await userRepo.getUserRole(user.uid);
        if (role == null || role.isEmpty){  //empty role
          emit(RoleNotSelected(user));
        } else{                  //role selected
          final updatedUser = AppUser(
            uid: user.uid,
            email: user.email,
            emailVerified: user.emailVerified,
            name: user.name,
            roleAllot: role,
          );
          _currentUser = updatedUser;
          emit(Authenticated(updatedUser));
        }
      } else{
        emit(Unauthenticated());
      }
    }
    catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await authRepo.sendEmailVerification();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Reload user to check email verification status
  Future<void> reloadUser() async {
    try {
      final user = await authRepo.reloadUser();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // check email verification
  Future<void> checkEmailVerification() async {
      final user = await authRepo.reloadUser();
      if (user != null) {
        final updatedUser = await authRepo.getCurrentUser();
        
        if (updatedUser?.emailVerified ?? false) {
          bool status = await userRepo.checkIfUserExists(updatedUser!.uid);
          if(!status){
              logger.d("Creating user in Firestore after email verification from checkEmailVerification:authCubit");
              final userName = _pendingUserName ?? updatedUser.name;
              await userRepo.saveUserData(
                user.uid,
                user.email,
                userName,
              );
              _pendingUserName = null;
              logger.d("Firestore user created successfully");
          } 
          else {
              logger.d("User already exists in Firestore");
          }

          //check for role selection
          final role = await userRepo.getUserRole(updatedUser.uid);
          if (role == null || role.isEmpty){
            emit(RoleNotSelected(updatedUser));
          } else{
            final userWithRole = AppUser(
              uid: updatedUser.uid, 
              email: updatedUser.email,
              emailVerified: updatedUser.emailVerified,
              name: updatedUser.name,
              roleAllot: role,
            );
            _currentUser = userWithRole;
            emit(Authenticated(userWithRole));
          }
        } else {
          emit(EmailNotVerified(updatedUser!));
        }
      }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await authRepo.sendEmailVerification();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  //save role selection
  Future<void> saveRoleSelection(String role, String address, String pincode, {String? businessName}) async{
    try{
      if (_currentUser == null){
        throw Exception('No user logged in');
      }
      logger.d("Starting saveRoleSelection for role: $role");
      emit(AuthLoading());

      //save role to users collection
      await userRepo.updateUserRole(_currentUser!.uid, role);
      logger.d("Role updated in users collection");

      //save data to role specific collections
      await userRepo.saveRoleData(
        _currentUser!.uid, 
        role, 
        address, 
        pincode, 
        businessName: businessName
      );
      logger.d("Role data saved to $role collection");
      //update current user with role
      final updatedUser = AppUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        emailVerified: _currentUser!.emailVerified,
        name: _currentUser!.name,
        roleAllot: role,
      );

      _currentUser = updatedUser;
      logger.d("Emitting Authenticated state with role: $role");
      emit(Authenticated(updatedUser));

      logger.d("Role selection saved successfully: $role");
      
    } catch(e){
      logger.e("Failed to save role selection: $e");
      emit(AuthError(e.toString()));
      if (_currentUser!=null){
        emit(RoleNotSelected(_currentUser!));
      } else{
        emit(Unauthenticated());
      }
    }
  }
}
