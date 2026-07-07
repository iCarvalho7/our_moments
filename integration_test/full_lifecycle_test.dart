import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Ciclo completo sem conta prévia
///
/// Exercita todo o app num único fluxo auto-limpante:
///   1. Cadastro (nova conta descartável)
///   2. Login
///   3. Criar timeline + definir data de início
///   4. Criar momento (título, descrição, tipo)
///   5. Editar momento
///   6. Excluir momento
///   7. Excluir timeline (via Ajustes da TimeLinePage)
///   8. Abrir mapa (verifica pins ou estado vazio)
///   9. Abrir ajustes de conta (verifica elementos básicos)
///  10. Excluir conta
///
/// Requer apenas `--dart-define=RUN_DESTRUCTIVE=true`.
/// O e-mail é gerado automaticamente; a senha usa o default "Teste123456"
/// (ou `--dart-define=TEST_SIGNUP_PASSWORD=<outra>`).
void fullLifecycleTests() {
  group('Ciclo completo (sem conta prévia)', () {
    testWidgets(
      'cadastro → timeline → momento → mapa → ajustes → limpeza total',
      (tester) async {
        final email = TestConfig.freshEmail();
        const password = TestConfig.signupPassword;
        final timelineName = 'E2E ${DateTime.now().millisecondsSinceEpoch}';
        final momentTitle = 'Momento E2E ${DateTime.now().millisecondsSinceEpoch}';
        final editedTitle = '$momentTitle (editado)';

        await launchLoggedOut(tester);

        // ── 1. Cadastro ──────────────────────────────────────────────────────
        await pumpUntilFound(tester, F.goToSignUp);
        await tester.tap(F.goToSignUp);
        await pumpUntilFound(tester, F.signUpTitle);

        await tester.enterText(F.signUpEmailField, email);
        await tester.enterText(F.signUpPasswordField, password);
        await tester.enterText(F.signUpConfirmPasswordField, password);
        await settle(tester);
        await tester.tap(F.signUpSubmit);

        // App exibe bottom sheet de sucesso; aguarda animação completar, depois toca.
        await pumpUntilFound(tester, F.signUpSuccessLoginButton);
        await settle(tester); // espera o sheet terminar de abrir
        await tester.tap(F.signUpSuccessLoginButton);
        await pumpUntilGone(tester, F.signUpTitle);

        // Signup redireciona de volta ao login; loga com a nova conta.
        if (F.feedAppBarTitle.evaluate().isEmpty) {
          await Flows.signIn(tester, email: email, password: password);
        }
        expect(F.feedAppBarTitle, findsWidgets,
            reason: 'Após login deve exibir o feed.');

        // ── 2. Criar timeline ────────────────────────────────────────────────
        // Para conta nova sem timelines, o card aparece sem precisar de scroll.
        await pumpUntilFound(tester, F.createTimelineCard);
        await tester.tap(F.createTimelineCard);
        await pumpUntilFound(tester, F.policySheetTitle);
        await tester.tap(F.createTimelineConfirm);

        // Nova timeline vazia: mostra o botão de data de início.
        await pumpUntilFound(tester, F.relationshipDateCta);
        await tester.tap(F.relationshipDateCta);
        await pumpUntilFound(tester, find.text('OK'));
        await tester.tap(find.text('OK'));
        await pumpUntilFound(tester, F.togetherLabel);
        expect(F.togetherLabel, findsWidgets,
            reason: 'Contador "Juntos há" deve aparecer após definir a data.');

        // ── 3. Criar momento ─────────────────────────────────────────────────
        await pumpUntilFound(tester, F.timelineNavCreate);
        await tester.tap(F.timelineNavCreate);
        await settle(tester);

        // Se aparecer o seletor de timeline (conta com múltiplas), usa a primeira.
        if (F.timelinePickerSheet.evaluate().isNotEmpty) {
          await tester.tap(find.byType(ListTile).first);
          await settle(tester);
        }

        await pumpUntilFound(tester, F.momentTitleField);
        await tester.enterText(F.momentTitleField, momentTitle);
        await tester.enterText(F.momentBodyField, 'Criado pelo teste de integração.');
        await tester.pump();
        await tester.tap(find.text('Romântico'));
        await tester.pump();
        // Date is required (isAllFieldsFilled checks dateTime != defaultDateTime).
        // _pickDateTime shows BOTH a date picker and then a time picker.
        await tester.tap(F.momentDateSelector);
        await pumpUntilFound(tester, find.text('OK'));
        await tester.tap(find.text('OK')); // date picker
        await pumpUntilFound(tester, find.text('OK'));
        await tester.tap(find.text('OK')); // time picker
        await settle(tester);
        await tester.tap(F.momentSaveNew);
        // Wait for AddOrEditMomentPage to pop back (save button disappears),
        // THEN wait for the moment card to appear in the timeline feed.
        await pumpUntilGone(tester, F.momentSave);
        await pumpUntilFound(tester, F.momentByTitle(momentTitle));
        await settle(tester); // garante que a página de criação completou o pop
        expect(F.momentByTitle(momentTitle), findsWidgets,
            reason: 'O momento criado deve aparecer no feed.');

        // ── 4. Editar momento ────────────────────────────────────────────────
        await tester.tap(F.momentByTitle(momentTitle).first);
        await pumpUntilFound(tester, F.momentSaveEdit);
        await settle(tester); // aguarda animação de push completar
        await tester.enterText(F.momentTitleField, editedTitle);
        await tester.pump();
        await tester.tap(F.momentSaveEdit);
        // Wait for AddOrEditMomentPage to pop before looking for the edited title.
        await pumpUntilGone(tester, F.momentSave);
        await pumpUntilFound(tester, F.momentByTitle(editedTitle));
        expect(F.momentByTitle(editedTitle), findsWidgets,
            reason: 'O título editado deve aparecer no feed.');

        // ── 5. Excluir momento ───────────────────────────────────────────────
        await tester.tap(F.momentByTitle(editedTitle).first);
        await pumpUntilFound(tester, F.momentSaveEdit);
        await settle(tester); // aguarda AppBar terminar de renderizar
        await tester.tap(F.momentDeleteButton);
        await pumpUntilFound(tester, F.momentDeleteConfirmTitle);
        await tester.tap(F.momentDeleteConfirmButton);
        await pumpUntilGone(tester, F.momentByTitle(editedTitle));
        expect(F.momentByTitle(editedTitle), findsNothing,
            reason: 'Momento excluído não deve mais aparecer.');

        // ── 6. Renomear + deletar timeline ───────────────────────────────────
        await pumpUntilFound(tester, F.timelineNavSettings);
        await tester.tap(F.timelineNavSettings);
        await pumpUntilFound(tester, F.timelineSettingsAppBar);

        // Renomeia para ter o nome exato que o campo de confirmação vai exigir.
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

        // De volta ao home (feed sem timelines).
        await pumpUntilFound(tester, F.feedAppBarTitle);

        // ── 7. Mapa ──────────────────────────────────────────────────────────
        // Uses "Momentos" nav (AllTimelinesMapPage) — always navigates even
        // when no timelines exist, unlike navMap which requires an active one.
        await pumpUntilFound(tester, F.navMoments);
        await tester.tap(F.navMoments);
        await pumpUntilFound(tester, F.allTimelinesMapTitle);
        expect(F.allTimelinesMapTitle, findsOneWidget);

        // Aguarda estado vazio (todas as timelines foram deletadas).
        final mapDeadline = DateTime.now().add(const Duration(seconds: 25));
        while (DateTime.now().isBefore(mapDeadline)) {
          await tester.pump(const Duration(milliseconds: 250));
          if (F.allTimelinesMapEmpty.evaluate().isNotEmpty) {
            break;
          }
        }

        // Volta para o home.
        // tester.pageBack() only finds BackButton; M3 AppBar uses IconButton
        // with BackButtonIcon() instead, so we navigate back via the navigator.
        tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
        await settle(tester);
        await pumpUntilFound(tester, F.feedAppBarTitle);

        // ── 8. Ajustes de conta ──────────────────────────────────────────────
        await Flows.openAccountSettings(tester);
        expect(F.accountTitle, findsOneWidget,
            reason: 'Tela "Minha conta" deve abrir.');
        expect(F.logoutButton, findsOneWidget);
        expect(F.deleteAccountButton, findsOneWidget);

        // ── 9. Excluir conta ─────────────────────────────────────────────────
        await _deleteAccount(tester, password: password);
        expect(F.loginButton, findsOneWidget,
            reason: 'Após excluir a conta deve voltar para o login.');
      },
      skip: !TestConfig.runDestructive,
    );
  });
}


Future<void> _deleteAccount(
  WidgetTester tester, {
  required String password,
}) async {
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  fullLifecycleTests();
}
