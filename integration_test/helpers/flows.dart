import 'package:flutter_test/flutter_test.dart';

import 'app_bootstrap.dart';
import 'finders.dart';
import 'test_config.dart';

/// High-level, reusable user journeys shared across the feature test files.
class Flows {
  const Flows._();

  /// Types [email] / [password] into the login form and taps "Entrar",
  /// then waits until the home feed ("Nossos Momentos") is visible.
  static Future<void> signIn(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    // We must be on the login screen.
    await pumpUntilFound(tester, F.loginButton);
    await tester.enterText(F.textFieldAt(0), email);
    await tester.enterText(F.textFieldAt(1), password);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    await tester.tap(F.loginButton);
    // Firebase Auth round-trip -> pushReplacement to the feed.
    await pumpUntilFound(tester, F.feedAppBarTitle);
  }

  /// Signs in with the shared QA account from [TestConfig].
  static Future<void> signInWithTestAccount(WidgetTester tester) {
    return signIn(
      tester,
      email: TestConfig.testEmail,
      password: TestConfig.testPassword,
    );
  }

  /// From the home feed, opens the account settings screen.
  static Future<void> openAccountSettings(WidgetTester tester) async {
    await pumpUntilFound(tester, F.navSettings);
    await tester.tap(F.navSettings);
    await pumpUntilFound(tester, F.accountTitle);
  }

  /// Logs out from the account settings screen and waits for the login screen.
  static Future<void> logout(WidgetTester tester) async {
    await pumpUntilFound(tester, F.logoutButton);
    await tester.tap(F.logoutButton);
    await pumpUntilFound(tester, F.loginButton);
  }
}
