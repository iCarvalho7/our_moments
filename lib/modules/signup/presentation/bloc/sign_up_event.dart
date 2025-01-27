part of 'sign_up_bloc.dart';

sealed class SignUpEvent {}

final class SignUpEventCreateAccount extends SignUpEvent {
  final String username;
  final String password;

  SignUpEventCreateAccount({required this.username, required this.password});
}
