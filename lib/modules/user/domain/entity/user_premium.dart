/// Premium entitlement bound to an individual user (`users/{uid}`).
///
/// Mirrors the per-user premium status. The [uid] is the Firestore doc id (not
/// a field of the doc), so it is provided from outside the JSON.
class UserPremium {
  /// Firebase Auth uid — also the Firestore doc id.
  final String uid;

  final String email;

  /// Premium entitlement mirror (the user's, persisted on the `users` doc).
  final bool isPremium;

  /// Expiry of the premium entitlement; null means lifetime.
  final DateTime? premiumUntil;

  UserPremium({
    required this.uid,
    this.email = '',
    this.isPremium = false,
    this.premiumUntil,
  });

  /// Effective premium: flag is on AND not expired (lifetime when null).
  bool get isActivePremium =>
      isPremium && (premiumUntil == null || premiumUntil!.isAfter(DateTime.now()));
}
