import '../../../core/premium/premium_feature.dart';
import '../entity/entitlement_status.dart';
import '../entity/premium_plan.dart';

/// Billing boundary over RevenueCat. The infra layer talks to the
/// `purchases_flutter` SDK; everything above stays SDK-agnostic.
abstract class PurchaseRepository {
  /// Plans available in the current/default offering, ordered for display.
  Future<List<PremiumPlan>> offerings();

  /// Purchases [plan] and returns the resulting entitlement status.
  Future<EntitlementStatus> purchase(PremiumPlan plan);

  /// Restores previous purchases and returns the resulting entitlement status.
  Future<EntitlementStatus> restore();

  /// Current entitlement status (no purchase flow).
  Future<EntitlementStatus> entitlementStatus();

  /// Presents the hosted paywall for [tier] and returns the resulting status.
  Future<EntitlementStatus> presentPaywall(PremiumTier tier);

  /// Presents the hosted Customer Center (manage/restore/cancel).
  Future<void> presentCustomerCenter();

  /// Whether the store SDK can be used on this build (mobile + configured).
  bool get isStoreAvailable;
}
