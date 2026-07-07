/// Central configuration for the E2E (integration) test suite.
///
/// Values are provided at run time via `--dart-define` (or a
/// `--dart-define-from-file`), so no real credentials live in the repo.
///
/// Example:
/// ```
/// fvm flutter test integration_test/app_test.dart \
///   --dart-define=TEST_EMAIL=e2e@nossosmomentos.app \
///   --dart-define=TEST_PASSWORD=SuperSecret123 \
///   --dart-define=RUN_DESTRUCTIVE=true
/// ```
///
/// IMPORTANT: this project has NO Firebase emulator configured
/// (`firebase.json` only wires production `nossosmomentos-22`). Every test
/// therefore talks to the REAL backend. Keep [testEmail] pointing at a
/// disposable QA account and only flip [runDestructive] on when you accept
/// that accounts/timelines/moments will actually be created and deleted.
class TestConfig {
  const TestConfig._();

  /// Existing QA account used by the feature tests (timeline / moment / map /
  /// settings) that assume a logged-in user with at least one timeline.
  static const String testEmail =
      String.fromEnvironment('TEST_EMAIL', defaultValue: '');

  /// Password for [testEmail].
  static const String testPassword =
      String.fromEnvironment('TEST_PASSWORD', defaultValue: '');

  /// Password used when the auth test registers a brand-new account. The email
  /// is generated per-run (see [freshEmail]) so signup never collides.
  static const String signupPassword =
      String.fromEnvironment('TEST_SIGNUP_PASSWORD', defaultValue: 'Teste123456');

  /// Master switch for destructive scenarios: account create/delete, timeline
  /// delete and moment delete. When `false` those tests are skipped so the
  /// suite can run read-only against a shared account.
  static const bool runDestructive =
      bool.fromEnvironment('RUN_DESTRUCTIVE', defaultValue: false);

  /// Whether the shared QA credentials were supplied. Feature tests that need a
  /// logged-in session skip themselves when this is `false`.
  static bool get hasCredentials =>
      testEmail.isNotEmpty && testPassword.isNotEmpty;

  /// A unique, valid e-mail for one signup run, e.g.
  /// `e2e+1712345678901@nossosmomentos.app`.
  static String freshEmail() =>
      'e2e+${DateTime.now().millisecondsSinceEpoch}@nossosmomentos.app';
}
