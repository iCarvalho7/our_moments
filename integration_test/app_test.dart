import 'package:integration_test/integration_test.dart';

import 'auth_test.dart' as auth;
import 'map_test.dart' as map;
import 'moment_test.dart' as moment;
import 'settings_test.dart' as settings;
import 'timeline_test.dart' as timeline;

/// Aggregated E2E suite for **Nossos Momentos**.
///
/// Runs every feature group in one session (single app bootstrap). Each group
/// self-skips when its prerequisites are missing (see [TestConfig]).
///
/// ---------------------------------------------------------------------------
/// HOW TO RUN
/// ---------------------------------------------------------------------------
/// A physical device or emulator is required (Firebase native plugins do not
/// run in headless `flutter test`). There is NO Firebase emulator configured,
/// so tests hit the real `nossosmomentos-22` backend — use a disposable QA
/// account.
///
///   # Read-only groups (login/logout, moment CRUD, map, settings):
///   fvm flutter test integration_test/app_test.dart \
///     --dart-define=TEST_EMAIL=e2e@nossosmomentos.app \
///     --dart-define=TEST_PASSWORD=SuperSecret123
///
///   # Include the destructive groups (account + timeline create/delete):
///   fvm flutter test integration_test/app_test.dart \
///     --dart-define=TEST_EMAIL=e2e@nossosmomentos.app \
///     --dart-define=TEST_PASSWORD=SuperSecret123 \
///     --dart-define=RUN_DESTRUCTIVE=true
///
///   # A single group:
///   fvm flutter test integration_test/moment_test.dart --dart-define=...
///
/// The QA account should already own at least one timeline so the moment / map
/// / settings groups have something to work with.
/// ---------------------------------------------------------------------------
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  auth.authTests();
  timeline.timelineTests();
  moment.momentTests();
  map.mapTests();
  settings.settingsTests();
}
