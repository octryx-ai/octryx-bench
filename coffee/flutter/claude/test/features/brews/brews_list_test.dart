import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/widgets/empty_state.dart';
import 'package:kaffee_begleiter/features/brews/presentation/brew_card.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';
import 'brew_test_helpers.dart';

void main() {
  testWidgets('AC1 espresso 18 to 36 g in 27 s shows 27 s in the list', (
    tester,
  ) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews');
    await tapKey(tester, 'action-add');
    await enterField(tester, 'grind', '12');
    await enterField(tester, 'dose', '18');
    await enterField(tester, 'yield', '36');
    await enterField(tester, 'shot', '27');
    await tapKey(tester, 'form-save');
    expect(find.text('27 s'), findsOneWidget);
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('Kenya AA'), findsOneWidget);
    final brew = s.data.brews.single;
    expect((brew.doseG, brew.yieldG, brew.shotTimeS), (18, 36, 27));
    expect(brew.grindSetting, 12);
    expect(s.data.packById(s.pack.id)!.remainingG, 232);
  });

  testWidgets('list is newest first with 88 dp cards and 12 dp gaps', (
    tester,
  ) async {
    final s = await seedBrewData();
    final old = await s.brew(time: 31, at: DateTime.utc(2026, 11, 10, 8));
    final mid = await s.brew(
      time: 27,
      rating: 4,
      at: DateTime.utc(2026, 11, 12, 8),
    );
    final recent = await s.brew(time: 22, at: DateTime.utc(2026, 11, 15, 8));
    await pumpApp(tester, data: s.data);
    await goTo(tester, '/brews');
    final tops = [
      for (final b in [recent, mid, old])
        tester.getTopLeft(find.byKey(Key('brew-${b.id}'))).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
    expect(tester.getSize(find.byKey(Key('brew-${mid.id}'))).height, 88);
    expect(tops[1] - tops[0], 88 + 12);
    expect(find.text('★ 4'), findsOneWidget);
    expect(find.text('22 s'), findsOneWidget);
    await tester.tap(find.byKey(Key('brew-${mid.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Brew detail'), findsOneWidget);
  });

  testWidgets('empty state in English keeps the filter entry', (tester) async {
    await pumpApp(tester, data: await loadTestAppData());
    await goTo(tester, '/brews');
    expect(
      find.descendant(
        of: find.byType(EmptyState),
        matching: find.byIcon(Icons.local_cafe),
      ),
      findsOneWidget,
    );
    expect(find.text('No brews yet'), findsOneWidget);
    expect(find.text('Log your first shot.'), findsOneWidget);
    expect(find.text('Log a brew'), findsWidgets);
    expect(find.byKey(const Key('start-filter')), findsOneWidget);
    await tester.tap(find.text('Log a brew').last);
    await tester.pumpAndSettle();
    expect(find.text('Add a grinder first'), findsOneWidget);
  });

  testWidgets('empty state in German', (tester) async {
    await pumpApp(
      tester,
      data: await loadTestAppData(),
      locale: const Locale('de'),
    );
    await goTo(tester, '/brews');
    expect(find.text('Noch keine Brühungen'), findsOneWidget);
    expect(find.text('Erfasse deinen ersten Shot.'), findsOneWidget);
    expect(find.text('Brühung erfassen'), findsWidgets);
  });

  testWidgets('German list shows the time unit and card for each brew', (
    tester,
  ) async {
    final s = await seedBrewData();
    await s.brew(time: 27, rating: 5, at: DateTime.utc(2026, 11, 15, 8));
    await pumpApp(tester, data: s.data, locale: const Locale('de'));
    await goTo(tester, '/brews');
    expect(find.byType(BrewCard), findsOneWidget);
    expect(find.text('27 s'), findsOneWidget);
    expect(find.text('★ 5'), findsOneWidget);
  });
}
