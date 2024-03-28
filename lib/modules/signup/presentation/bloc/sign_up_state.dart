part of 'sign_up_bloc.dart';

sealed class SignUpState {}

final class SignUpInitial extends SignUpState {}

final class SignUpLoading extends SignUpState {}

final class SignUpError extends SignUpState {}

final class SignUpSuccess extends SignUpState {}