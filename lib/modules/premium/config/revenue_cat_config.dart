/// RevenueCat configuration.
///
/// Currently wired to the RevenueCat **Test Store** key (`test_...`). The Test
/// Store lets us drive real purchase/restore/paywall flows entirely inside
/// RevenueCat — without App Store Connect / Google Play products — so debug
/// builds can exercise the hosted paywalls and Customer Center end to end.
///
/// ⚠️ FOR PRODUCTION: replace the Test Store key below with the platform-
/// specific public SDK keys (Android `goog_...`, iOS `appl_...`) from
/// RevenueCat → Project → API keys, and split [androidApiKey]/[iosApiKey] again.
///
/// ⚠️ EXTERNAL SETUP REQUIRED in the RevenueCat dashboard (see the closing
/// notes in the PR): create the Test Store products, attach them to the
/// entitlements [individualEntitlementId] and [coupleEntitlementId], create the
/// two named Offerings ('individual' and 'couple'), and design a Paywall on
/// each offering (required by `RevenueCatUI.presentPaywall`).
///
/// When the key is a placeholder, [isConfigured] stays false and the app skips
/// `Purchases.configure` so web/dev builds keep working without billing.
class RevenueCatConfig {
  RevenueCatConfig._();

  /// RevenueCat Test Store key (cross-platform). Replace with `goog_...` for
  /// production Android. TODO(owner): swap for the real Play key before release.
  static const String androidApiKey = 'test_KnSIKUUHdYWuFwPppBLgTMqTRXt';

  /// RevenueCat Test Store key (cross-platform). Replace with `appl_...` for
  /// production iOS. TODO(owner): swap for the real App Store key before release.
  static const String iosApiKey = 'test_KnSIKUUHdYWuFwPppBLgTMqTRXt';

  /// Entitlement identifier for the individual (per-user) plan. Must match the
  /// RevenueCat dashboard exactly. Unlocks the individual-tier features.
  static const String individualEntitlementId = 'premium_individual';

  /// Entitlement identifier for the couple (per-timeline) plan. Must match the
  /// RevenueCat dashboard exactly. Superset of the individual entitlement.
  static const String coupleEntitlementId = 'premium_couple';

  /// Placeholder prefix marking a key that still needs to be filled in.
  static const String _placeholderPrefix = 'TODO_';

  /// Whether real keys have been provided. When false the app must NOT call
  /// `Purchases.configure` (avoids a runtime crash with the placeholder key).
  static bool get isConfigured =>
      !androidApiKey.startsWith(_placeholderPrefix) &&
      !iosApiKey.startsWith(_placeholderPrefix);
}
