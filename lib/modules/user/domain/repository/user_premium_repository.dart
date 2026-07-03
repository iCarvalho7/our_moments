import '../entity/user_premium.dart';

abstract class UserPremiumRepository {
  /// Reads the per-user premium doc. Returns null when there is no doc.
  Future<UserPremium?> getByUid(String uid);

  /// Mirrors the premium entitlement onto `users/{uid}` (set/merge).
  /// [premiumUntil] null means lifetime.
  Future<UserPremium> updatePremium(
    String uid, {
    required String email,
    required bool isPremium,
    DateTime? premiumUntil,
  });

  /// Deletes the per-user premium doc `users/{uid}`.
  Future<void> delete(String uid);
}
