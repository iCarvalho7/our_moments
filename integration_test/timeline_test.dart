import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Timeline (linha do tempo)
///
/// Self-contained: creates a throwaway account, exercises the full timeline
/// lifecycle, then deletes the account.
///
///   - Criar nova timeline
///   - Editar: data de início e nome
///   - Deletar: fluxo de confirmação em dois passos
///   - Excluir conta
void timelineTests() {
  group('Timeline', () {
    testWidgets(
      'cria, edita (data e nome) e deleta uma linha do tempo',
      (tester) async {
        final email = TestConfig.freshEmail();
        const password = TestConfig.signupPassword;
        final name = 'E2E Linha ${DateTime.now().millisecondsSinceEpoch}';

        await launchLoggedOut(tester);
        await Flows.signUpAndSignIn(tester, email: email, password: password);

        // --- Criar linha do tempo -------------------------------------
        await _scrollToVertical(tester, F.createTimelineCard);
        await tester.tap(F.createTimelineCard);
        await pumpUntilFound(tester, F.policySheetTitle);
        await tester.tap(F.createTimelineConfirm);

        // Nova timeline (vazia) abre com o botão de data de início.
        await pumpUntilFound(tester, F.relationshipDateCta);

        // --- Editar: data de início -----------------------------------
        await tester.tap(F.relationshipDateCta);
        await pumpUntilFound(tester, find.text('OK'));
        await tester.tap(find.text('OK'));
        await pumpUntilFound(tester, F.togetherLabel);
        expect(F.togetherLabel, findsWidgets,
            reason: 'Após definir a data deve mostrar "Juntos há".');

        // --- Editar: nome (tela de ajustes da timeline) ---------------
        await tester.tap(F.timelineNavSettings);
        // Wait for SettingsSuccess (name field only appears after BLoC loads).
        await pumpUntilFound(tester, F.timelineNameField);

        await tester.ensureVisible(F.timelineNameField);
        await tester.enterText(F.timelineNameField, name);
        await tester.ensureVisible(F.saveTimelineChanges.first);
        await tester.tap(F.saveTimelineChanges.first);
        await settle(tester);

        // --- Deletar linha do tempo -----------------------------------
        await tester.ensureVisible(F.deleteTimelineButton);
        await tester.tap(F.deleteTimelineButton);
        await pumpUntilFound(tester, F.deleteTimelineSheetTitle);

        final checks = find.byType(Checkbox);
        await tester.tap(checks.at(0));
        await tester.pump();
        await tester.tap(checks.at(1));
        await tester.pump();
        await tester.tap(F.continueButton);
        await settle(tester);

        final confirmField = F.fieldByHint('Digite o nome aqui');
        await pumpUntilFound(tester, confirmField);
        await tester.enterText(confirmField, name);
        await tester.pump();
        await tester.tap(F.deleteConfirmButton);
        await pumpUntilGone(tester, F.deleteTimelineSheetTitle);

        // De volta ao home (feed sem timelines).
        await pumpUntilFound(tester, F.feedAppBarTitle);

        // --- Excluir conta -------------------------------------------
        await Flows.deleteAccount(tester, password: password);
        expect(F.loginButton, findsOneWidget,
            reason: 'Após excluir a conta deve voltar para o login.');
      },
      skip: !TestConfig.runDestructive,
    );
  });
}

Future<void> _scrollToVertical(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  final vertical = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: vertical.first,
    maxScrolls: 60,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  timelineTests();
}
