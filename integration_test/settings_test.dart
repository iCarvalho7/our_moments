import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Ajustes / Configurações
///
/// Creates a throwaway account, opens the account settings screen and asserts
/// the basic elements are present, then deletes the account.
void settingsTests() {
  group('Ajustes / Configurações', () {
    testWidgets('abre a tela de ajustes e mostra os elementos básicos', (tester) async {
      final email = TestConfig.freshEmail();
      const password = TestConfig.signupPassword;

      await launchLoggedOut(tester);
      await Flows.signUpAndSignIn(tester, email: email, password: password);

      // Wait for feed to fully load before navigating away (avoids race
      // condition on NewFeedCubit when logout/delete clears the route stack).
      await pumpUntilFound(tester, F.createTimelineCard);

      await Flows.openAccountSettings(tester);

      expect(F.accountTitle, findsOneWidget);
      expect(
        find.text('Lembrança diária às 9h'),
        findsWidgets,
        reason: 'A tela deve exibir o toggle de lembrança diária.',
      );
      expect(F.logoutButton, findsOneWidget, reason: 'Deve existir o botão de logout.');
      expect(F.deleteAccountButton, findsOneWidget, reason: 'Deve existir o botão de exclusão de conta.');

      // Cleanup: delete account (we're already on the settings screen so
      // tap the delete button directly without re-navigating).
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

      expect(F.loginButton, findsOneWidget, reason: 'Após excluir a conta deve voltar para o login.');
    }, skip: !TestConfig.runDestructive);
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  settingsTests();
}
