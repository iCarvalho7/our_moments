import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

/// All feature toggles in the app.
///
/// To add a new toggle:
///   1. Add a value to this enum with a doc comment.
///   2. Add its Remote Config key to [FeatureToggleManager._remoteKeys].
///   3. Add its safe local default to [FeatureToggleManager._defaults].
///      (prefer `false` — fail-safe / off by default)
///   4. Create the matching parameter in Firebase Remote Config console.
enum AppFeatureToggle {
  /// RevenueCat in-app purchase SDK.
  ///
  /// When disabled, the SDK is never initialized, no paywall is shown,
  /// and [PremiumService] falls back to its own rules (debug → couple tier,
  /// release → free tier).
  revenueCat,

  /// Gamification layer (couple + individual streaks, points, achievements).
  ///
  /// When disabled, no progress is computed or awarded on moment creation and
  /// the streak/achievement surfaces are hidden — the app behaves as before.
  gamification,

  /// Celebration overlay (confetti + reward card) shown after a moment is
  /// created. When disabled, creation just pops back silently as before.
  momentCelebration,

  /// Per-moment "private" visibility (only the author can see it inside a
  /// shared timeline). When disabled, the private toggle is hidden and every
  /// moment is treated as shared.
  privateMoments,
}

@lazySingleton
class FeatureToggleManager {
  FeatureToggleManager(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  // Remote Config parameter names — must match the Firebase console.
  static const Map<AppFeatureToggle, String> _remoteKeys = {
    AppFeatureToggle.revenueCat: 'feature_revenue_cat',
    AppFeatureToggle.gamification: 'feature_gamification',
    AppFeatureToggle.momentCelebration: 'feature_moment_celebration',
    AppFeatureToggle.privateMoments: 'feature_private_moments',
  };

  // Local fallback values used before the first successful fetch
  // and for any toggle absent from Remote Config.
  static const Map<AppFeatureToggle, bool> _defaults = {
    AppFeatureToggle.revenueCat: false,
    // Purely local UI reward with no backend dependency — safe to ship on.
    AppFeatureToggle.momentCelebration: true,
    // Depend on Firestore data/rules being in place — off until provisioned.
    AppFeatureToggle.gamification: false,
    AppFeatureToggle.privateMoments: false,
  };

  /// Fetches and activates Remote Config values.
  ///
  /// Called once at startup (after [configureDependencies]). Local [_defaults]
  /// are registered so every toggle has a value even before the first fetch.
  /// Fetch errors are swallowed — the app falls back to [_defaults] silently.
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _remoteConfig.setDefaults({
      for (final entry in _remoteKeys.entries)
        entry.value: _defaults[entry.key] ?? false,
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Network unavailable or quota exceeded — _defaults remain active.
    }
  }

  /// Returns `true` when [toggle] is enabled.
  ///
  /// Reads the activated Remote Config value. Falls back to [_defaults] when
  /// the toggle has no registered Remote Config key.
  bool isEnabled(AppFeatureToggle toggle) {
    final key = _remoteKeys[toggle];
    if (key == null) return _defaults[toggle] ?? false;
    return _remoteConfig.getBool(key);
  }
}
