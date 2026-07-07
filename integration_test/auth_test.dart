import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Autenticação / Conta
///
/// Covers the four requested account scenarios:
///   1. Criar conta (registro com email/senha)
///   2. Login com conta existente
///   3. Logout
///   4. Deletar conta
///
/// The account create + delete scenarios are DESTRUCTIVE (they hit real
/// Firebase Auth), so they only run when `--dart-define=RUN_DESTRUCTIVE=true`.
/// They are self-cleaning: the lifecycle test registers a throwaway account and
/// deletes it at the end.
void authTests() {
  group('Autenticação / Conta', () {
    // ------------------------------------------------------------------
    // 2 + 3: Login com conta existente e logout (não destrutivo).
    // Requires TEST_EMAIL / TEST_PASSWORD of an existing account.
    // ------------------------------------------------------------------
    testWidgets(
      'faz login com conta existente e depois logout',
      (tester) async {
        await launchLoggedOut(tester);

        // Login
        await Flows.signInWithTestAccount(tester);
        expect(F.feedAppBarTitle, findsWidgets,
            reason: 'Após o login deve abrir o feed "Nossos Momentos".');
        // Aguarda feed carregar para evitar race condition no logout.
        await settle(tester);

        // Logout
        await Flows.openAccountSettings(tester);
        await Flows.logout(tester);
        expect(F.loginButton, findsOneWidget,
            reason: 'Após o logout deve voltar para a tela de login.');
      },
      skip: !TestConfig.hasCredentials,
    );

    // ------------------------------------------------------------------
    // 1 + 2 + 3 + 4: Ciclo completo de conta (destrutivo, auto-limpante).
    // Registra uma conta nova, faz login/logout e por fim exclui a conta.
    // ------------------------------------------------------------------
    testWidgets(
      'cria conta, faz login, logout e exclui a conta (ciclo completo)',
      (tester) async {
        final email = TestConfig.freshEmail();
        const password = TestConfig.signupPassword;

        await launchLoggedOut(tester);

        // --- 1. Criar conta -------------------------------------------
        await pumpUntilFound(tester, F.goToSignUp);
        await tester.tap(F.goToSignUp);
        await pumpUntilFound(tester, F.signUpTitle);

        await tester.enterText(F.signUpEmailField, email);
        await tester.enterText(F.signUpPasswordField, password);
        await tester.enterText(F.signUpConfirmPasswordField, password);
        await settle(tester);
        await tester.tap(F.signUpSubmit);

        // On success a bottom sheet appears; wait for it to finish opening then tap.
        await pumpUntilFound(tester, F.signUpSuccessLoginButton);
        await settle(tester); // let the sheet slide fully into view
        await tester.tap(F.signUpSuccessLoginButton);
        await pumpUntilGone(tester, F.signUpTitle);
        await settle(tester);

        // --- 2. Login com a conta recém-criada ------------------------
        if (F.feedAppBarTitle.evaluate().isEmpty) {
          await Flows.signIn(tester, email: email, password: password);
        }
        expect(F.feedAppBarTitle, findsWidgets,
            reason: 'A conta criada deve conseguir logar e ver o feed.');
        // Aguarda NewFeedCubit terminar de carregar (conta nova → sem timelines).
        // Sem isso, o logout dispara pushNamedAndRemoveUntil antes do cubit
        // completar, causando "Cannot emit new states after calling close".
        await pumpUntilFound(tester, F.createTimelineCard);

        // --- 3. Logout ------------------------------------------------
        await Flows.openAccountSettings(tester);
        await Flows.logout(tester);
        expect(F.loginButton, findsOneWidget);

        // --- 4. Login novamente e excluir a conta ---------------------
        await Flows.signIn(tester, email: email, password: password);
        // Wait for feed to load again before navigating to settings.
        await pumpUntilFound(tester, F.createTimelineCard);
        await Flows.openAccountSettings(tester);
        await _deleteAccount(tester, password: password);

        expect(F.loginButton, findsOneWidget,
            reason: 'Após excluir a conta deve voltar para o login.');
      },
      skip: !TestConfig.runDestructive,
    );
  });
}

/// From the account settings screen, opens the delete-account sheet, ticks the
/// two acknowledgement checkboxes, confirms, and handles the reauthentication
/// password dialog that Firebase requires for a recent-login-sensitive delete.
Future<void> _deleteAccount(
  WidgetTester tester, {
  required String password,
}) async {
  await pumpUntilFound(tester, F.deleteAccountButton);
  await tester.tap(F.deleteAccountButton);

  // Confirmation sheet: acknowledge both consequences to enable the button.
  await pumpUntilFound(tester, find.text('Excluir sua conta?'));
  final checkboxes = find.byType(Checkbox);
  await tester.tap(checkboxes.at(0));
  await tester.pump();
  await tester.tap(checkboxes.at(1));
  await tester.pump();

  await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir conta'));
  await settle(tester);

  // Firebase often requires a fresh re-auth before deletion.
  final reauth = find.text('Confirme sua identidade');
  if (reauth.evaluate().isNotEmpty) {
    // The dialog has a single password TextField.
    await tester.enterText(find.byType(TextField).last, password);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
  }

  await pumpUntilFound(tester, F.loginButton);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  authTests();
}
