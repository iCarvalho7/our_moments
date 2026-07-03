import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';

/// A purchasable premium plan, mapped from a RevenueCat `Package`.
///
/// Kept SDK-agnostic so the domain/presenter layers never depend on
/// `purchases_flutter` directly; the datasource carries the underlying package
/// via [rawPackageId] and resolves it again at purchase time.
class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.rawPackageId,
    required this.title,
    required this.priceString,
    required this.duration,
    required this.tier,
  });

  /// Stable identifier (the RevenueCat package identifier).
  final String id;

  /// Which tier this plan unlocks (individual or couple). Derived from the
  /// Offering the package belongs to.
  final PremiumTier tier;

  /// Raw package identifier used by the datasource to resolve the package.
  final String rawPackageId;

  /// Localized product title (store-provided).
  final String title;

  /// Localized, currency-formatted price (e.g. "R$ 19,90").
  final String priceString;

  /// Coarse plan duration, used for PT-BR labels in the paywall.
  final PremiumPlanDuration duration;
}

/// Coarse plan duration buckets used to label plans in PT-BR.
enum PremiumPlanDuration {
  monthly('Mensal'),
  yearly('Anual'),
  lifetime('Vitalício'),
  other('Plano');

  const PremiumPlanDuration(this.label);

  /// PT-BR label shown on the paywall.
  final String label;
}
