import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> signIn(String username, String password);

  Future<void> signUp(String username, String password);

  bool isUserAuthenticated();

  User? getCurrentUser();

  Future<void> logout();

  /// Re-authenticates the current user with their password. Required by Firebase
  /// before sensitive operations (e.g. account deletion) when the last sign-in
  /// is too old. Throws when there is no current user or the password is wrong.
  Future<void> reauthenticateWithPassword(String password);

  /// Permanently deletes the current user's Firebase Auth account. May throw a
  /// [FirebaseAuthException] with code `requires-recent-login`, in which case the
  /// caller must reauthenticate and retry.
  Future<void> deleteAccount();
}