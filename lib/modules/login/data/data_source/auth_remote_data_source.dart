import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<void> signIn(String username, String password);

  Future<void> signUp(String username, String password);

  bool isUserAuthenticated();

  User? getCurrentUser();

  Future<void> logout();
}