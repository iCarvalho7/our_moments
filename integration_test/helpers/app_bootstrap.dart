import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/firebase_options.dart';
import 'package:nossos_momentos/main.dart';
import 'package:nossos_momentos/modules/core/feature_toggles/feature_toggle_manager.dart';

/// Boots the real app for E2E tests.
///
/// It mirrors the essential part of `main()` (Firebase, date formatting,
/// dependency injection, feature toggles) but deliberately SKIPS RevenueCat,
/// local notifications and the Crashlytics error handlers. Those subsystems are
/// either device-store-bound or would swallow test failures, so leaving them
/// out keeps the suite deterministic while still exercising the production
/// widget tree via [MyApp].
bool _initialized = false;

Future<void> _ensureInitialized() async {
  if (_initialized) return;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  configureDependencies();
  try {
    // Remote Config may be unreachable in CI; tolerate it so gating falls back
    // to its baked-in defaults instead of crashing the whole run.
    await getIt<FeatureToggleManager>().initialize();
  } catch (_) {
    // ignore: intentionally non-fatal.
  }
  _initialized = true;
}

/// Signs the current Firebase user out so every test starts from a known,
/// logged-out state at the login screen.
Future<void> resetAuth() async {
  await _ensureInitialized();
  try {
    await FirebaseAuth.instance.signOut();
  } catch (_) {
    // No user / already signed out.
  }
}

/// Launches [MyApp] and settles the first frame. Does NOT touch auth state, so
/// callers decide (via [resetAuth] or by logging in) what the starting point
/// should be.
Future<void> launchApp(WidgetTester tester) async {
  await _ensureInitialized();
  await tester.pumpWidget(const MyApp());
  await settle(tester);
}

/// Launches the app already signed out, landing on the login screen.
Future<void> launchLoggedOut(WidgetTester tester) async {
  await resetAuth();
  await launchApp(tester);
}

/// A [pumpAndSettle] that never throws when a screen keeps an infinite
/// animation alive (shimmer loaders, map tiles). Falls back to a bounded number
/// of manual pumps.
Future<void> settle(
  WidgetTester tester, {
  Duration step = const Duration(milliseconds: 120),
  int maxPumps = 40,
}) async {
  try {
    await tester.pumpAndSettle(step, EnginePhase.sendSemanticsUpdate, step * maxPumps);
  } catch (_) {
    for (var i = 0; i < maxPumps; i++) {
      await tester.pump(step);
    }
  }
}

/// Pumps repeatedly (allowing real async work such as Firebase round-trips to
/// complete) until [finder] matches at least one widget, or [timeout] elapses.
///
/// Use this instead of [WidgetTester.pumpAndSettle] whenever the next state
/// depends on the network — `pumpAndSettle` would time out on pending futures.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 25),
  Duration step = const Duration(milliseconds: 250),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure(
    'Timed out after ${timeout.inSeconds}s waiting for: $finder',
  );
}

/// Pumps until [finder] no longer matches anything (a screen was dismissed).
Future<void> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 25),
  Duration step = const Duration(milliseconds: 250),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (finder.evaluate().isEmpty) return;
  }
  throw TestFailure(
    'Timed out after ${timeout.inSeconds}s waiting for "$finder" to disappear',
  );
}
