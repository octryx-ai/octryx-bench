import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';
import '../brews/brew_test_helpers.dart';

void main() {
  for (final (locale, title, action) in [
    (const Locale('en'), 'Nothing here yet', 'Add bean'),
    (const Locale('de'), 'Noch nichts da', 'Bohne hinzufügen'),
  ]) {
    testWidgets('empty state in $locale', (tester) async {
      await pumpApp(tester, data: await loadTestAppData(), locale: locale);
      expect(find.text(title), findsOneWidget);
      expect(find.text(action), findsWidgets);
    });
  }

  testWidgets('filled Heute: warnings, ready beans, last brew, FAB', (
    tester,
  ) async {
    final s = await seedBrewData(hardnessPpm: 300);
    await s.brew(rating: 4);
    await pumpApp(tester, data: s.data, height: tallViewport);
    expect(find.byKey(const Key('today-warnings')), findsOneWidget);
    expect(find.text('Ready now'), findsOneWidget);
    expect(find.text('Kenya AA'), findsWidgets);
    expect(find.text('Last brew'), findsOneWidget);
    expect(find.byKey(const Key('today-last-none')), findsNothing);
    expect(find.byKey(const Key('today-ready-none')), findsNothing);
    expect(find.byKey(const Key('today-new-brew')), findsOneWidget);
    expect(find.text('New brew'), findsOneWidget);
  });

  testWidgets('the FAB opens the brew form', (tester) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await tapKey(tester, 'today-new-brew');
    expect(find.text('Log a brew'), findsWidgets);
  });

  testWidgets('the care tile links to Pflege', (tester) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await tapKey(tester, 'link-/care');
    expect(find.text('Care'), findsWidgets);
  });

  testWidgets('care and water banners have their own action labels', (
    tester,
  ) async {
    final s = await seedBrewData(hardnessPpm: 300);
    await pumpApp(tester, data: s.data, height: tallViewport);
    expect(find.text('Open care'), findsWidgets);
    expect(find.text('Open water profile'), findsOneWidget);
  });
}
