import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Momentos
///
/// Covers the requested moment scenarios in a single self-cleaning journey:
///   - Criar momento (título, descrição, tipo/categoria)
///   - Visualizar o momento (aparece no feed)
///   - Editar momento existente
///   - Excluir momento
///
/// Media (photos/videos) is intentionally NOT exercised: it requires the native
/// gallery/file picker which cannot be automated headlessly. Media is optional
/// on a moment, so a text-only moment is valid.
///
/// Runs against the real backend, so it needs the shared QA credentials. It
/// deletes the moment it creates, leaving no residue.
void momentTests() {
  group('Momentos', () {
    testWidgets(
      'cria, visualiza, edita e exclui um momento',
      (tester) async {
        final title = 'E2E Momento ${DateTime.now().millisecondsSinceEpoch}';
        final editedTitle = '$title (editado)';
        const body = 'Descrição criada pelo teste de integração.';

        await launchLoggedOut(tester);
        await Flows.signInWithTestAccount(tester);

        // --- Criar momento --------------------------------------------
        await _openMomentForm(tester);
        await tester.enterText(_titleField, title);
        await tester.enterText(_bodyField, body);
        await tester.pump();

        // Categoria/tipo: seleciona o chip "Romântico" (MomentType.romantic).
        await tester.tap(find.text('Romântico'));
        await tester.pump();

        await tester.tap(F.momentSaveNew);
        await pumpUntilFound(tester, F.momentByTitle(title));

        // --- Visualizar -----------------------------------------------
        expect(F.momentByTitle(title), findsWidgets,
            reason: 'O momento criado deve aparecer no feed.');

        // --- Editar ----------------------------------------------------
        await tester.tap(F.momentByTitle(title).first);
        await pumpUntilFound(tester, F.momentSaveEdit);
        await tester.enterText(_titleField, editedTitle);
        await tester.pump();
        await tester.tap(F.momentSaveEdit);
        await pumpUntilFound(tester, F.momentByTitle(editedTitle));
        expect(F.momentByTitle(editedTitle), findsWidgets,
            reason: 'O título editado deve refletir no feed.');

        // --- Excluir ---------------------------------------------------
        await tester.tap(F.momentByTitle(editedTitle).first);
        await pumpUntilFound(tester, F.momentSaveEdit);
        await tester.tap(find.byIcon(CupertinoIcons.delete));
        await pumpUntilFound(tester, F.momentDeleteConfirmTitle);
        await tester.tap(F.momentDeleteConfirmButton);
        await pumpUntilGone(tester, F.momentByTitle(editedTitle));
        expect(F.momentByTitle(editedTitle), findsNothing,
            reason: 'O momento excluído não deve mais aparecer no feed.');
      },
      skip: !TestConfig.hasCredentials,
    );
  });
}

/// Taps the "Criar" nav action and lands on the add-moment form, choosing the
/// first timeline if the app asks which timeline to write to.
Future<void> _openMomentForm(WidgetTester tester) async {
  await pumpUntilFound(tester, F.navCreate);
  await tester.tap(F.navCreate);
  await settle(tester);

  // If the account can edit more than one timeline, a picker sheet appears.
  if (F.timelinePickerSheet.evaluate().isNotEmpty) {
    await tester.tap(find.byType(ListTile).first);
    await settle(tester);
  }
  await pumpUntilFound(tester, F.momentTitleHint);
}

/// The moment form has exactly two text fields: [0] title, [1] description.
Finder get _titleField => find.byType(TextField).at(0);
Finder get _bodyField => find.byType(TextField).at(1);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  momentTests();
}
