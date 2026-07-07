import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Mapa
///
/// Self-contained: creates a throwaway account + timeline (required so that
/// the "Mapa" nav item navigates to MomentsMapPage), opens the map, verifies it
/// reaches a valid terminal state (pins or empty state), then deletes the account.
///
/// The timeline is left orphaned in Firestore after account deletion — this is
/// acceptable for a test environment since no user has credentials for the
/// throwaway account.
void mapTests() {
  group('Mapa', () {
    testWidgets('abre o mapa e mostra os pins ou o estado vazio', (tester) async {
      final email = TestConfig.freshEmail();
      const password = TestConfig.signupPassword;

      await launchLoggedOut(tester);
      await Flows.signUpAndSignIn(tester, email: email, password: password);

      // --- Criar timeline (necessária para o navMap funcionar) ------
      // navMap (key_bottom_nav_map) calls _openTimeline() on
      // NewSelectTimeLinePage, which only navigates when activeTimelineId
      // is set (i.e., at least one timeline exists).
      await pumpUntilFound(tester, F.createTimelineCard);
      await tester.tap(F.createTimelineCard);
      await pumpUntilFound(tester, F.policySheetTitle);
      await tester.tap(F.createTimelineConfirm);
      await pumpUntilFound(tester, F.relationshipDateCta);

      // Volta para o home para que o NewFeedCubit carregue a timeline
      // antes de usar navMap.
      tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
      await settle(tester);
      await pumpUntilFound(tester, F.feedAppBarTitle);

      // Espera a timeline aparecer no feed (desaparece o card de criação).
      await pumpUntilGone(tester, F.createTimelineCard);

      // --- Abrir o mapa ---------------------------------------------
      await pumpUntilFound(tester, F.navMap);
      await tester.tap(F.navMap);
      await pumpUntilFound(tester, F.mapTitle);
      expect(F.mapTitle, findsOneWidget);

      // Aguarda até o mapa renderizar ou o estado vazio aparecer.
      await _waitForMapOrEmpty(tester);

      final isEmpty = F.mapEmpty.evaluate().isNotEmpty;
      if (isEmpty) {
        expect(F.mapEmpty, findsOneWidget, reason: 'Sem momentos com localização → estado vazio.');
      } else {
        expect(find.byType(FlutterMap), findsOneWidget, reason: 'Com momentos localizados o mapa deve renderizar.');
        expect(F.mapFilterAll, findsWidgets, reason: 'A barra de filtro por linha do tempo deve aparecer.');
      }

      // Volta para o home.
      tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
      await settle(tester);
      await pumpUntilFound(tester, F.feedAppBarTitle);

      // --- Excluir conta -------------------------------------------
      await Flows.deleteAccount(tester, password: password);
      expect(F.loginButton, findsOneWidget, reason: 'Após excluir a conta deve voltar para o login.');
    }, skip: !TestConfig.runDestructive);
  });
}

Future<void> _waitForMapOrEmpty(WidgetTester tester) async {
  final deadline = DateTime.now().add(const Duration(seconds: 25));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (find.byType(FlutterMap).evaluate().isNotEmpty || F.mapEmpty.evaluate().isNotEmpty) {
      return;
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  mapTests();
}
