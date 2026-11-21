import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaffee_begleiter/features/styleguide/presentation/styleguide_screen.dart';

import '../helpers.dart';

void main() {
  const screens = {
    '/': 'Today',
    '/brews': 'Brew',
    '/care': 'Care',
    '/brews/new': 'Log a brew',
    '/brews/detail': 'Brew detail',
    '/filter': 'Guided filter',
  };

  for (final width in [390.0, 1280.0]) {
    for (final e in screens.entries) {
      testWidgets('${e.key} shows title and Coming soon at $width', (
        tester,
      ) async {
        await pumpApp(tester, width: width);
        await goTo(tester, e.key);
        expect(find.text('Coming soon'), findsOneWidget);
        expect(find.text(e.value), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('more menu and style guide are reachable', (tester) async {
    await pumpApp(tester);
    await goTo(tester, '/more');
    await tester.tap(find.byKey(const Key('link-/styleguide')));
    await tester.pumpAndSettle();
    expect(find.byType(StyleGuideScreen), findsOneWidget);
  });

  testWidgets('beans and brews link to detail, form and filter', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('nav-brews')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start-filter')));
    await tester.pumpAndSettle();
    expect(find.text('Guided filter'), findsWidgets);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('screen fills viewport bottom on short content', (tester) async {
    await pumpApp(tester, width: 1280, height: 900);
    await goTo(tester, '/water');
    final scaffold = tester.getRect(find.byType(Scaffold).first);
    expect(scaffold.bottom, 900);
  });
}
