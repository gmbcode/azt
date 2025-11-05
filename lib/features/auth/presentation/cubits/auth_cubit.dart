//FOR STATE MANAGEMENT

import 'package:azt/features/auth/domain/entities/app_user.dart';
import 'package:azt/features/auth/domain/repos/auth_repo.dart';
import 'package:azt/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState>{
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

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
      emit(Authenticated(user));
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
        emit(Authenticated(user));
      } else{
        emit(Unauthenticated());
      }
    }
    catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //register with email + pw
  Future<void> register(String name, String email, String pw) async{
    try{
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);

      if (user != null){
        _currentUser = user;
        emit(Authenticated(user));
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
        emit(Authenticated(user));
      } else{
        emit(Unauthenticated());
      }
    }
    catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}
