import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';
import 'package:material_ui/material_ui.dart';

import '../../form_helpers.dart';
import '../../helpers.dart';
import 'brew_test_helpers.dart';

void main() {
  Future<void> openDetail(
    WidgetTester tester,
    BrewSeed s,
    String id, {
    Locale locale = const Locale('en'),
  }) async {
    await pumpApp(tester, data: s.data, height: tallViewport, locale: locale);
    await goTo(tester, '/brews');
    await tester.tap(find.byKey(Key('brew-$id')));
    await tester.pumpAndSettle();
  }

  String sentence(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('rec-sentence'))).data!;

  testWidgets('AC5 sour 27 s at 12.0 recommends grind 11.5', (tester) async {
    final s = await seedBrewData();
    final b = await s.brew(taste: Taste.sour, at: DateTime.utc(2026, 11, 15));
    await openDetail(tester, s, b.id);
    expect(find.text('Recommendation'), findsOneWidget);
    expect(sentence(tester), 'Set grind to 11.5');
    expect(find.text('12.0'), findsOneWidget);
    expect(find.text('1:2.0'), findsOneWidget);
    expect(find.text('27 s'), findsOneWidget);
    expect(find.text('Sour'), findsOneWidget);
    expect(find.text('Linea'), findsOneWidget);
  });

  testWidgets('AC5 sour 27 s in German reads Mahlgrad auf 11.5', (
    tester,
  ) async {
    final s = await seedBrewData();
    final b = await s.brew(taste: Taste.sour, at: DateTime.utc(2026, 11, 15));
    await openDetail(tester, s, b.id, locale: const Locale('de'));
    expect(find.text('Empfehlung'), findsOneWidget);
    expect(sentence(tester), 'Mahlgrad auf 11.5');
    expect(find.text('Grund'), findsOneWidget);
    expect(find.text('Quelle'), findsOneWidget);
    expect(find.text('Nächster Versuch'), findsOneWidget);
    expect(find.text('Sauer'), findsOneWidget);
  });

  testWidgets('AC5 balanced 27 s means no change', (tester) async {
    final s = await seedBrewData();
    final b = await s.brew(
      taste: Taste.balanced,
      at: DateTime.utc(2026, 11, 15),
    );
    await openDetail(tester, s, b.id);
    expect(sentence(tester), 'No change');
  });

  testWidgets('AC5 end of scale keeps 1.0 and shows the hint', (tester) async {
    final s = await seedBrewData();
    final b = await s.brew(
      setting: 1,
      taste: Taste.sour,
      at: DateTime.utc(2026, 11, 15),
    );
    await openDetail(tester, s, b.id);
    expect(sentence(tester), 'Grind stays at 1.0');
    expect(find.text('End of scale'), findsOneWidget);
  });

  testWidgets('AC6 water outside the range comes first', (tester) async {
    final s = await seedBrewData(hardnessPpm: 300, roast: '2026-11-12');
    final b = await s.brew(taste: Taste.sour, at: DateTime.utc(2026, 11, 15));
    await openDetail(tester, s, b.id);
    expect(
      sentence(tester),
      'Check water first: hardness 300 ppm, SCA 50–175 ppm',
    );
  });

  testWidgets('AC6 resting pack comes second', (tester) async {
    final s = await seedBrewData(roast: '2026-11-12');
    final b = await s.brew(taste: Taste.sour, at: DateTime.utc(2026, 11, 15));
    await openDetail(tester, s, b.id);
    expect(sentence(tester), startsWith('Let the pack rest ('));
    expect(sentence(tester), endsWith(' days left)'));
  });

  testWidgets('AC6 no water profile asks for water values', (tester) async {
    final s = await seedBrewData(machineWater: false);
    final b = await s.brew(taste: Taste.sour, at: DateTime.utc(2026, 11, 15));
    await openDetail(tester, s, b.id);
    expect(sentence(tester), 'Enter water values');
    expect(find.text('Default without source'), findsOneWidget);
  });

  testWidgets('AC6 German water sentence', (tester) async {
    final s = await seedBrewData(hardnessPpm: 300);
    final b = await s.brew(at: DateTime.utc(2026, 11, 15));
    await openDetail(tester, s, b.id, locale: const Locale('de'));
    expect(
      sentence(tester),
      'Wasser zuerst prüfen: Härte 300 ppm, SCA 50–175 ppm',
    );
  });

  testWidgets('AC7 reason and source URL are visible', (tester) async {
    final s = await seedBrewData();
    final b = await s.brew(time: 38, at: DateTime.utc(2026, 11, 15));
    await openDetail(tester, s, b.id);
    expect(sentence(tester), 'Set grind to 13.0');
    expect(
      find.text(
        'Shot time 38 s is above the target window: grind coarser by 2 steps.',
      ),
      findsOneWidget,
    );
    final source = tester.widget<SelectableText>(
      find.byKey(const Key('rec-source')),
    );
    expect(source.data, startsWith('https://'));
    expect(source.style!.decoration, TextDecoration.underline);
  });

  testWidgets('AC8 Next try opens the form with the values taken over', (
    tester,
  ) async {
    final s = await seedBrewData();
    final b = await s.brew(
      taste: Taste.sour,
      rating: 4,
      at: DateTime.utc(2026, 11, 15),
    );
    await openDetail(tester, s, b.id);
    await tapKey(tester, 'next-try');
    expect(find.text('Log a brew'), findsOneWidget);
    expect(fieldText(tester, 'grind'), '11.5');
    expect(fieldText(tester, 'dose'), '18');
    expect(fieldText(tester, 'yield'), '36');
    expect(fieldText(tester, 'purge'), '0');
    expect(fieldText(tester, 'shot'), '');
    await enterField(tester, 'shot', '28');
    await tapKey(tester, 'form-save');
    expect(s.data.brews, hasLength(2));
    final created = s.data.brews.first;
    expect(created.grindSetting, 11.5);
    expect(created.machineId, s.machine.id);
    expect(created.packId, s.pack.id);
    expect(created.waterProfileId, s.water.id);
    expect(created.taste, isNull);
    expect(created.rating, isNull);
  });

  testWidgets('deleting a brew removes it from the list', (tester) async {
    final s = await seedBrewData();
    final b = await s.brew(at: DateTime.utc(2026, 11, 15));
    await openDetail(tester, s, b.id);
    await tester.tap(find.byKey(const Key('action-delete')));
    await tester.pumpAndSettle();
    expect(s.data.brews, isEmpty);
    expect(find.text('No brews yet'), findsOneWidget);
  });
}
