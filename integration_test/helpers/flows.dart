import 'package:flutter/material.dart';
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
    await pumpUntilFound(tester, F.loginButton);
    await tester.enterText(F.textFieldAt(0), email);
    await tester.enterText(F.textFieldAt(1), password);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    await tester.tap(F.loginButton);
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

  /// Creates a fresh throwaway account via the signup flow and signs in.
  /// Leaves the app on the home feed (NewSelectTimeLinePage).
  static Future<void> signUpAndSignIn(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await pumpUntilFound(tester, F.goToSignUp);
    await tester.tap(F.goToSignUp);
    await pumpUntilFound(tester, F.signUpTitle);

    await tester.enterText(F.signUpEmailField, email);
    await tester.enterText(F.signUpPasswordField, password);
    await tester.enterText(F.signUpConfirmPasswordField, password);
    await settle(tester);
    await tester.tap(F.signUpSubmit);

    await pumpUntilFound(tester, F.signUpSuccessLoginButton);
    await settle(tester);
    await tester.tap(F.signUpSuccessLoginButton);
    await pumpUntilGone(tester, F.signUpTitle);
    await settle(tester);

    if (F.feedAppBarTitle.evaluate().isEmpty) {
      await signIn(tester, email: email, password: password);
    }
    await pumpUntilFound(tester, F.feedAppBarTitle);
  }

  /// From the home feed (NewSelectTimeLinePage), opens the account settings.
  /// Must be called while the home feed's bottom nav is visible.
  static Future<void> openAccountSettings(WidgetTester tester) async {
    await pumpUntilFound(tester, F.navSettings);
    await tester.tap(F.navSettings);
    await pumpUntilFound(tester, F.accountTitle);
  }

  /// Navigates back to the home feed (NewSelectTimeLinePage) by popping routes
  /// until the home app-bar title is visible. Safe to call even if already home.
  /// Uses Navigator.maybePop so it works on Material 3 (no BackButton widget).
  static Future<void> navigateToHome(WidgetTester tester) async {
    while (F.feedAppBarTitle.evaluate().isEmpty) {
      tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
      await tester.pump(const Duration(milliseconds: 300));
    }
    await settle(tester);
  }

  /// From the home feed, opens account settings and deletes the account.
  /// Handles the confirmation checkboxes and optional Firebase re-auth dialog.
  static Future<void> deleteAccount(
    WidgetTester tester, {
    required String password,
  }) async {
    await openAccountSettings(tester);

    await pumpUntilFound(tester, F.deleteAccountButton);
    await tester.tap(F.deleteAccountButton);

    await pumpUntilFound(tester, find.text('Excluir sua conta?'));
    final checkboxes = find.byType(Checkbox);
    await tester.tap(checkboxes.at(0));
    await tester.pump();
    await tester.tap(checkboxes.at(1));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir conta'));
    await settle(tester);

    final reauth = find.text('Confirme sua identidade');
    if (reauth.evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).last, password);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
    }

    await pumpUntilFound(tester, F.loginButton);
  }

  /// Logs out from the account settings screen and waits for the login screen.
  static Future<void> logout(WidgetTester tester) async {
    await pumpUntilFound(tester, F.logoutButton);
    await tester.tap(F.logoutButton);
    await pumpUntilFound(tester, F.loginButton);
  }
}
