import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Momentos
///
/// Self-contained: creates a throwaway account + timeline, exercises the full
/// moment lifecycle, deletes the timeline, then deletes the account.
///
///   - Criar momento (título, descrição, tipo/categoria)
///   - Visualizar o momento (aparece no feed)
///   - Editar momento existente
///   - Excluir momento
void momentTests() {
  group('Momentos', () {
    testWidgets(
      'cria, visualiza, edita e exclui um momento',
      (tester) async {
        final email = TestConfig.freshEmail();
        const password = TestConfig.signupPassword;
        final timelineName = 'E2E ${DateTime.now().millisecondsSinceEpoch}';
        final title = 'E2E Momento ${DateTime.now().millisecondsSinceEpoch}';
        final editedTitle = '$title (editado)';

        await launchLoggedOut(tester);
        await Flows.signUpAndSignIn(tester, email: email, password: password);

        // --- Criar timeline (necessária para criar momentos) ----------
        await pumpUntilFound(tester, F.createTimelineCard);
        await tester.tap(F.createTimelineCard);
        await pumpUntilFound(tester, F.policySheetTitle);
        await tester.tap(F.createTimelineConfirm);
        await pumpUntilFound(tester, F.relationshipDateCta);
        await tester.tap(F.relationshipDateCta);
        await pumpUntilFound(tester, find.text('OK'));
        await tester.tap(find.text('OK'));
        await pumpUntilFound(tester, F.togetherLabel);

        // --- Criar momento --------------------------------------------
        await pumpUntilFound(tester, F.timelineNavCreate);
        await tester.tap(F.timelineNavCreate);
        await settle(tester);

        if (F.timelinePickerSheet.evaluate().isNotEmpty) {
          await tester.tap(find.byType(ListTile).first);
          await settle(tester);
        }

        await pumpUntilFound(tester, F.momentTitleField);
        await tester.enterText(F.momentTitleField, title);
        await tester.enterText(F.momentBodyField, 'Descrição criada pelo teste.');
        await tester.pump();
        await tester.tap(find.text('Romântico'));
        await tester.pump();
        await tester.tap(F.momentDateSelector);
        await pumpUntilFound(tester, find.text('OK'));
        await tester.tap(find.text('OK')); // date picker
        await pumpUntilFound(tester, find.text('OK'));
        await tester.tap(find.text('OK')); // time picker
        await settle(tester);
        await tester.tap(F.momentSaveNew);
        await pumpUntilGone(tester, F.momentSave);
        await pumpUntilFound(tester, F.momentByTitle(title));
        await settle(tester);

        // --- Visualizar -----------------------------------------------
        expect(F.momentByTitle(title), findsWidgets,
            reason: 'O momento criado deve aparecer no feed.');

        // --- Editar ----------------------------------------------------
        await tester.tap(F.momentByTitle(title).first);
        await pumpUntilFound(tester, F.momentSaveEdit);
        await settle(tester);
        await tester.enterText(F.momentTitleField, editedTitle);
        await tester.pump();
        await tester.tap(F.momentSaveEdit);
        await pumpUntilGone(tester, F.momentSave);
        await pumpUntilFound(tester, F.momentByTitle(editedTitle));
        await settle(tester);
        expect(F.momentByTitle(editedTitle), findsWidgets,
            reason: 'O título editado deve refletir no feed.');

        // --- Excluir momento ------------------------------------------
        await tester.tap(F.momentByTitle(editedTitle).first);
        await pumpUntilFound(tester, F.momentSaveEdit);
        await settle(tester);
        await tester.tap(F.momentDeleteButton);
        await pumpUntilFound(tester, F.momentDeleteConfirmTitle);
        await tester.tap(F.momentDeleteConfirmButton);
        await pumpUntilGone(tester, F.momentByTitle(editedTitle));
        expect(F.momentByTitle(editedTitle), findsNothing,
            reason: 'O momento excluído não deve mais aparecer no feed.');

        // --- Excluir timeline -----------------------------------------
        // Rename first so we know the exact name for the confirmation field.
        await pumpUntilFound(tester, F.timelineNavSettings);
        await tester.tap(F.timelineNavSettings);
        // Wait for SettingsSuccess (name field only appears after BLoC loads).
        await pumpUntilFound(tester, F.timelineNameField);

        await tester.ensureVisible(F.timelineNameField);
        await tester.enterText(F.timelineNameField, timelineName);
        await tester.ensureVisible(F.saveTimelineChanges.first);
        await tester.tap(F.saveTimelineChanges.first);
        await settle(tester);

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
        await tester.enterText(confirmField, timelineName);
        await tester.pump();
        await tester.tap(F.deleteConfirmButton);
        await pumpUntilGone(tester, F.deleteTimelineSheetTitle);
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  momentTests();
}
