part of 'login_bloc.dart';

sealed class LoginEvent {}

final class LoginEventSignIn extends LoginEvent {
  final String username;
  final String password;

  LoginEventSignIn({required this.username, required this.password});
}

final class LoginEventSignUp extends LoginEvent {}
