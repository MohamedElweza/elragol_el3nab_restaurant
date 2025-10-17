import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSignInSuccess extends AuthState {
  final UserModel user;
  AuthSignInSuccess(this.user);
}

class AuthSignUpSuccess extends AuthState {
  final UserModel user;
  AuthSignUpSuccess(this.user);
}

class SendOtpSuccess extends AuthState {}

class ResetPasswordSuccess extends AuthState {
  final String message;

  ResetPasswordSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthLoggedOut extends AuthState {}
