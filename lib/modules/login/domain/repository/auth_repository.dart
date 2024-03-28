abstract class AuthRepository {
  Future<void> signIn(String username, String password);

  Future<void> signUp(String username, String password);
}