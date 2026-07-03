import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';

/// SDK-agnostic snapshot of the user's premium entitlement, derived from the
/// RevenueCat `CustomerInfo`.
class EntitlementStatus {
  const EntitlementStatus({
    required this.isActive,
    required this.tier,
    this.expirationDate,
  });

  /// Whether a premium entitlement is currently active.
  final bool isActive;

  /// Which tier the active entitlement grants. [PremiumTier.free] when nothing
  /// is active. Couple supersedes individual when both are active.
  final PremiumTier tier;

  /// When the entitlement expires; null means active with no expiry
  /// (e.g. a lifetime/non-consumable purchase).
  final DateTime? expirationDate;

  /// Convenience for the "not premium" case.
  const EntitlementStatus.inactive()
      : isActive = false,
        tier = PremiumTier.free,
        expirationDate = null;
}
