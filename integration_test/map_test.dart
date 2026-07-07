import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_bootstrap.dart';
import 'helpers/finders.dart';
import 'helpers/flows.dart';
import 'helpers/test_config.dart';

/// E2E — Mapa
///
/// Opens the moments map and verifies it reaches a valid terminal state:
///   - the map screen loads ("Mapa dos momentos");
///   - either located moments are shown (a [FlutterMap] with its filter bar)
///     or the "no located moments" empty state is displayed.
///
/// Actually tapping individual map pins to navigate between moments is
/// positional and cannot be driven reliably without `Key`s on the markers, so
/// that step is asserted at the "map is interactive" level rather than by
/// tapping a specific pin. See the task notes for the suggested marker keys.
void mapTests() {
  group('Mapa', () {
    testWidgets(
      'abre o mapa e mostra os pins ou o estado vazio',
      (tester) async {
        await launchLoggedOut(tester);
        await Flows.signInWithTestAccount(tester);

        // "Mapa" bottom-nav action opens the moments map.
        await pumpUntilFound(tester, F.navMap);
        await tester.tap(F.navMap);
        await pumpUntilFound(tester, F.mapTitle);
        expect(F.mapTitle, findsOneWidget);

        // Wait until either the map or the empty state settles in.
        await _waitForMapOrEmpty(tester);

        final isEmpty = F.mapEmpty.evaluate().isNotEmpty;
        if (isEmpty) {
          expect(F.mapEmpty, findsOneWidget,
              reason: 'Conta sem momentos localizados -> estado vazio.');
        } else {
          expect(find.byType(FlutterMap), findsOneWidget,
              reason: 'Com momentos localizados o mapa deve renderizar.');
          expect(F.mapFilterAll, findsWidgets,
              reason: 'A barra de filtro por linha do tempo deve aparecer.');
        }
      },
      skip: !TestConfig.hasCredentials,
    );
  });
}

/// Polls until the map view or the empty-state text is on screen.
Future<void> _waitForMapOrEmpty(WidgetTester tester) async {
  final deadline = DateTime.now().add(const Duration(seconds: 25));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (find.byType(FlutterMap).evaluate().isNotEmpty ||
        F.mapEmpty.evaluate().isNotEmpty) {
      return;
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  mapTests();
}
