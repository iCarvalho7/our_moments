import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Timeline (linha do tempo)
///
/// Full self-cleaning lifecycle:
///   - Criar nova timeline (cartão "Criar nova linha do tempo" -> política ->
///     "Criar linha do tempo").
///   - Editar: define a data de início do relacionamento (contador) e o nome
///     (tela "Gerenciar acesso" -> "Personalizar").
///   - Deletar: fluxo de confirmação em dois passos (checkboxes -> digitar o
///     nome exato).
///
/// This is the most navigation-heavy journey and it creates + deletes real
/// backend data, so it is DESTRUCTIVE (needs RUN_DESTRUCTIVE=true) and needs the
/// shared QA credentials.
void timelineTests() {
  group('Timeline', () {
    testWidgets(
      'cria, edita (data e nome) e deleta uma linha do tempo',
      (tester) async {
        final name = 'E2E Linha ${DateTime.now().millisecondsSinceEpoch}';

        await launchLoggedOut(tester);
        await Flows.signInWithTestAccount(tester);

        // --- Criar linha do tempo -------------------------------------
        await _scrollToVertical(tester, F.createTimelineCard);
        await tester.tap(F.createTimelineCard);
        await pumpUntilFound(tester, F.policySheetTitle);
        // Mantém a política padrão ("individual") e confirma.
        await tester.tap(F.createTimelineConfirm);

        // A nova timeline (vazia) abre com o contador de relacionamento.
        await pumpUntilFound(tester, F.relationshipDateCta);

        // --- Editar: data de início do relacionamento -----------------
        await tester.tap(F.relationshipDateCta);
        await pumpUntilFound(tester, find.text('OK')); // Material date picker
        await tester.tap(find.text('OK')); // aceita a data padrão (hoje)
        await pumpUntilFound(tester, F.togetherLabel);
        expect(F.togetherLabel, findsWidgets,
            reason: 'Após definir a data deve mostrar "Juntos há".');

        // --- Editar: nome (tela de ajustes da timeline) ---------------
        await tester.tap(F.navSettings); // "Ajustes" no menu inferior
        await pumpUntilFound(tester, F.timelineSettingsAppBar);

        final nameField = F.fieldByHint('Nome da linha do tempo');
        await tester.ensureVisible(nameField);
        await tester.enterText(nameField, name);
        await tester.ensureVisible(F.saveTimelineChanges.first);
        await tester.tap(F.saveTimelineChanges.first);
        await settle(tester);

        // --- Deletar linha do tempo -----------------------------------
        await tester.ensureVisible(F.deleteTimelineButton);
        await tester.tap(F.deleteTimelineButton);
        await pumpUntilFound(tester, F.deleteTimelineSheetTitle);

        // Passo 1: marcar os dois checkboxes e continuar.
        final checks = find.byType(Checkbox);
        await tester.tap(checks.at(0));
        await tester.pump();
        await tester.tap(checks.at(1));
        await tester.pump();
        await tester.tap(F.continueButton);
        await settle(tester);

        // Passo 2: digitar o nome exato para habilitar a exclusão.
        final confirmField = F.fieldByHint('Digite o nome aqui');
        await pumpUntilFound(tester, confirmField);
        await tester.enterText(confirmField, name);
        await tester.pump();
        await tester.tap(F.deleteConfirmButton);

        // A folha some quando a exclusão é confirmada.
        await pumpUntilGone(tester, F.deleteTimelineSheetTitle);
      },
      skip: !(TestConfig.runDestructive && TestConfig.hasCredentials),
    );
  });
}

/// Scrolls the main vertical feed until [finder] is visible.
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
