import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const compact = [
    'nav-today',
    'nav-beans',
    'nav-brews',
    'nav-equipment',
    'nav-more',
  ];
  const wide = [
    'nav-today',
    'nav-beans',
    'nav-brews',
    'nav-equipment',
    'nav-water',
    'nav-care',
    'nav-settings',
  ];

  testWidgets('phone 390: bottom bar with 5 items, no overflow', (
    tester,
  ) async {
    await pumpApp(tester, width: 390);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    for (final k in compact) {
      expect(find.byKey(Key(k)), findsOneWidget, reason: k);
    }
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet 700: rail with 5 destinations', (tester) async {
    await pumpApp(tester, width: 700);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(
      find.byType(NavigationRailDestination, skipOffstage: false),
      findsNothing,
    );
    for (final k in compact) {
      expect(find.byKey(Key(k)), findsOneWidget, reason: k);
    }
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop 1280: 240 dp sidebar, 7 entries, fills viewport', (
    tester,
  ) async {
    await pumpApp(tester, width: 1280, height: 800);
    final sidebar = find.byKey(const Key('app-sidebar'));
    expect(sidebar, findsOneWidget);
    expect(tester.getSize(sidebar).width, 240);
    expect(tester.getBottomLeft(sidebar).dy, 800);
    for (final k in wide) {
      expect(find.byKey(Key(k)), findsOneWidget, reason: k);
    }
    expect(find.byKey(const Key('nav-more')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone: Mehr leads to Wasser, Pflege, Einstellungen', (
    tester,
  ) async {
    await pumpApp(tester, width: 390);
    await tester.tap(find.byKey(const Key('nav-more')));
    await tester.pumpAndSettle();
    for (final route in ['/water', '/care', '/settings']) {
      expect(find.byKey(Key('link-$route')), findsOneWidget);
    }
    expect(find.byKey(const Key('link-/styleguide')), findsOneWidget);
  });
}
