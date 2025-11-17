import 'package:azt/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

//initial
class AuthInitial extends AuthState{}

//loading..
class AuthLoading extends AuthState{}

//authenticated
class Authenticated extends AuthState{
  final AppUser user;
  Authenticated(this.user);
}

//unauthenticated
class Unauthenticated extends AuthState{}

//email not verified
class EmailNotVerified extends AuthState {
  final AppUser user;
  EmailNotVerified(this.user);
}

//role not selected
class RoleNotSelected extends AuthState{
  final AppUser user;
  RoleNotSelected(this.user);
}
//errors
class AuthError extends AuthState{
  final String message;
  AuthError(this.message);
}
