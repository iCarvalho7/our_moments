import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Ajustes / Configurações
///
/// Opens the account settings screen (bottom nav "Ajustes") and asserts the
/// basic elements are present. Read-only: nothing is changed or deleted.
void settingsTests() {
  group('Ajustes / Configurações', () {
    testWidgets(
      'abre a tela de ajustes e mostra os elementos básicos',
      (tester) async {
        await launchLoggedOut(tester);
        await Flows.signInWithTestAccount(tester);

        await Flows.openAccountSettings(tester);

        // Basic elements of the "Minha conta" screen.
        expect(F.accountTitle, findsOneWidget);
        expect(find.text('Lembrança diária às 9h'), findsWidgets,
            reason: 'A tela deve exibir o toggle de lembrança diária.');
        expect(F.logoutButton, findsOneWidget,
            reason: 'Deve existir o botão de logout.');
        expect(F.deleteAccountButton, findsOneWidget,
            reason: 'Deve existir o botão de exclusão de conta.');
      },
      skip: !TestConfig.hasCredentials,
    );
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  settingsTests();
}
