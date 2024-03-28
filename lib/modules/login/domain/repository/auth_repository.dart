abstract class AuthRepository {
  Future<void> signIn(String username, String password);
}