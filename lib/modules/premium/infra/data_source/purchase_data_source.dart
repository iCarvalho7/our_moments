import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../config/revenue_cat_config.dart';
import '../../domain/entity/entitlement_status.dart';
import '../../domain/entity/premium_plan.dart';
import '../../domain/purchase_exception.dart';

/// Talks to the RevenueCat (`purchases_flutter`) SDK and maps its types to the
/// SDK-agnostic domain entities. This is the ONLY place that imports the SDK
/// (besides `main.dart`'s `configure`).
abstract class PurchaseDataSource {
  Future<List<PremiumPlan>> getOfferings();
  Future<EntitlementStatus> purchase(PremiumPlan plan);
  Future<EntitlementStatus> restore();
  Future<EntitlementStatus> entitlementStatus();

  /// Presents the RevenueCat-hosted paywall for [tier]'s offering and returns
  /// the real entitlement status after it closes (covers purchased, restored
  /// and cancelled — idempotent).
  Future<EntitlementStatus> presentPaywall(PremiumTier tier);

  /// Presents the RevenueCat-hosted Customer Center (manage/restore/cancel).
  Future<void> presentCustomerCenter();

  /// Whether the store SDK can be used on this build (mobile + configured).
  bool get isStoreAvailable;
}

@Injectable(as: PurchaseDataSource)
class RevenueCatPurchaseDataSourceImpl extends PurchaseDataSource {
  /// Offering identifier (dashboard) holding the individual-tier packages.
  static const String _individualOfferingId = 'individual';

  /// Offering identifier (dashboard) holding the couple-tier packages.
  static const String _coupleOfferingId = 'couple';

  @override
  Future<List<PremiumPlan>> getOfferings() async {
    _ensureAvailable();
    final offerings = await Purchases.getOfferings();

    // Two named Offerings, one per tier. A missing offering is ignored (empty
    // list) so a half-configured dashboard still surfaces whatever exists.
    final individual = offerings.all[_individualOfferingId];
    final couple = offerings.all[_coupleOfferingId];

    return [
      ...?individual?.availablePackages
          .map((p) => _toPlan(p, PremiumTier.individual)),
      ...?couple?.availablePackages.map((p) => _toPlan(p, PremiumTier.couple)),
    ];
  }

  @override
  Future<EntitlementStatus> purchase(PremiumPlan plan) async {
    _ensureAvailable();
    // Resolve the underlying package again from its tier's offering — the
    // domain entity intentionally does not carry the SDK `Package`.
    final package = await _findPackage(plan.rawPackageId, plan.tier);
    final info = await Purchases.purchasePackage(package);
    return _toStatus(info);
  }

  @override
  Future<EntitlementStatus> restore() async {
    _ensureAvailable();
    final info = await Purchases.restorePurchases();
    return _toStatus(info);
  }

  @override
  Future<EntitlementStatus> entitlementStatus() async {
    if (!_purchasesAvailable) return const EntitlementStatus.inactive();
    final info = await Purchases.getCustomerInfo();
    return _toStatus(info);
  }

  @override
  Future<EntitlementStatus> presentPaywall(PremiumTier tier) async {
    _ensureAvailable();
    final offerings = await Purchases.getOfferings();
    final offeringId =
        tier == PremiumTier.couple ? _coupleOfferingId : _individualOfferingId;
    final offering = offerings.all[offeringId];
    if (offering == null) {
      throw const PurchasesUnavailableException('Plano indisponível no momento.');
    }

    // The result is intentionally ignored: after the paywall closes for ANY
    // reason we re-read the real entitlement, which is idempotent and also
    // covers restores done inside the paywall.
    await RevenueCatUI.presentPaywall(
      offering: offering,
      displayCloseButton: true,
    );
    return _toStatus(await Purchases.getCustomerInfo());
  }

  @override
  Future<void> presentCustomerCenter() async {
    _ensureAvailable();
    await RevenueCatUI.presentCustomerCenter();
  }

  @override
  bool get isStoreAvailable => _purchasesAvailable;

  /// The store SDK is only usable on Android/iOS AND once real RevenueCat keys
  /// are set (otherwise `main.dart` skips `Purchases.configure`, so any SDK call
  /// would crash). In debug builds purchases are disabled (premium is unlocked
  /// globally via PremiumService, so the paywall just shows the info card).
  bool get _purchasesAvailable =>
      !kIsWeb && !kDebugMode && RevenueCatConfig.isConfigured;

  /// Throws a user-facing [PurchasesUnavailableException] when purchases can't
  /// run on this build, so the bloc can surface a clear message instead of a
  /// raw SDK crash.
  void _ensureAvailable() {
    if (kIsWeb) {
      throw const PurchasesUnavailableException();
    }
    if (!RevenueCatConfig.isConfigured) {
      throw const PurchasesUnavailableException(
        'As assinaturas ainda não estão disponíveis. Tente novamente em breve.',
      );
    }
  }

  Future<Package> _findPackage(String identifier, PremiumTier tier) async {
    final offerings = await Purchases.getOfferings();
    final offeringId = tier == PremiumTier.couple
        ? _coupleOfferingId
        : _individualOfferingId;
    final offering = offerings.all[offeringId];
    final package = offering?.getPackage(identifier);
    if (package == null) {
      throw StateError(
        'Package "$identifier" not found in offering "$offeringId".',
      );
    }
    return package;
  }

  PremiumPlan _toPlan(Package package, PremiumTier tier) {
    final product = package.storeProduct;
    return PremiumPlan(
      id: package.identifier,
      rawPackageId: package.identifier,
      title: product.title,
      priceString: product.priceString,
      duration: _durationFor(package.packageType),
      tier: tier,
    );
  }

  PremiumPlanDuration _durationFor(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return PremiumPlanDuration.monthly;
      case PackageType.annual:
        return PremiumPlanDuration.yearly;
      case PackageType.lifetime:
        return PremiumPlanDuration.lifetime;
      default:
        return PremiumPlanDuration.other;
    }
  }

  EntitlementStatus _toStatus(CustomerInfo info) {
    // Couple supersedes individual: check it first.
    final couple = info.entitlements.active[RevenueCatConfig.coupleEntitlementId];
    if (couple != null && couple.isActive) {
      return _statusFrom(couple, PremiumTier.couple);
    }

    final individual =
        info.entitlements.active[RevenueCatConfig.individualEntitlementId];
    if (individual != null && individual.isActive) {
      return _statusFrom(individual, PremiumTier.individual);
    }

    return const EntitlementStatus.inactive();
  }

  EntitlementStatus _statusFrom(EntitlementInfo entitlement, PremiumTier tier) {
    final expiration = entitlement.expirationDate;
    return EntitlementStatus(
      isActive: true,
      tier: tier,
      expirationDate: expiration == null ? null : DateTime.tryParse(expiration),
    );
  }
}
