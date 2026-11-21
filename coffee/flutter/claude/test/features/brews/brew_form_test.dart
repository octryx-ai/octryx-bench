import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';
import 'brew_test_helpers.dart';

void main() {
  testWidgets('AC2 validation errors per field', (tester) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    await enterField(tester, 'grind', '12.3');
    await enterField(tester, 'dose', '3');
    await enterField(tester, 'yield', '100');
    await enterField(tester, 'purge', '60');
    await enterField(tester, 'shot', '130');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a value between 5 and 40'), findsOneWidget);
    expect(find.text('Enter a value between 3 and 12'), findsOneWidget);
    expect(find.text('Enter a value between 0 and 50'), findsOneWidget);
    expect(find.text('Enter a value between 1 and 120'), findsOneWidget);
    expect(
      find.text("Value is not on the grinder's scale (step 0.5)"),
      findsOneWidget,
    );
    expect(s.data.brews, isEmpty);
  });

  testWidgets('empty dose, yield and time are errors', (tester) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a value between 5 and 40'), findsOneWidget);
    expect(find.text('Enter a value between 1 and 4'), findsOneWidget);
    expect(find.text('Enter a value between 1 and 120'), findsOneWidget);
  });

  testWidgets('AC2 hints: add a grinder first and add a machine first', (
    tester,
  ) async {
    final data = await loadTestAppData();
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/brews/new');
    expect(find.text('Add a grinder first'), findsOneWidget);
    expect(find.text('Add a machine first'), findsOneWidget);
    await tapKey(tester, 'form-save');
    expect(data.brews, isEmpty);
    expect(find.text('Log a brew'), findsOneWidget);
  });

  testWidgets('German hints and labels', (tester) async {
    final data = await loadTestAppData();
    await pumpApp(
      tester,
      data: data,
      height: tallViewport,
      locale: const Locale('de'),
    );
    await goTo(tester, '/brews/new');
    expect(find.text('Zuerst eine Mühle anlegen'), findsOneWidget);
    expect(find.text('Zuerst eine Maschine anlegen'), findsOneWidget);
    expect(find.text('Spülmenge'), findsOneWidget);
    expect(find.text('Shot-Zeit (s)'), findsOneWidget);
    expect(find.text('Timer starten'), findsOneWidget);
    expect(find.text('Ausgewogen', skipOffstage: false), findsOneWidget);
  });

  testWidgets('AC3 not enough beans shows the remaining grams', (tester) async {
    final s = await seedBrewData();
    await s.data.updatePack(s.pack.copyWith(remainingG: 20.5));
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    await enterField(tester, 'dose', '18');
    await enterField(tester, 'purge', '3');
    await enterField(tester, 'yield', '36');
    await enterField(tester, 'shot', '27');
    await tapKey(tester, 'form-save');
    expect(
      find.text('Not enough beans in the pack (20.5 g left)'),
      findsOneWidget,
    );
    expect(s.data.brews, isEmpty);
    expect(s.data.packById(s.pack.id)!.remainingG, 20.5);
    await s.data.updatePack(s.pack.copyWith(remainingG: 20));
    await tapKey(tester, 'form-save');
    expect(find.text('Not enough beans in the pack (20 g left)'), findsOne);
  });

  testWidgets('AC3 purge banner after a bean change prefills the purge', (
    tester,
  ) async {
    final s = await seedBrewData();
    await s.brew(at: DateTime.utc(2026, 11, 16, 8));
    final other = await s.data.addBean(
      name: 'Santos',
      roaster: 'R',
      roastLevel: s.bean.roastLevel,
      kind: s.bean.kind,
    );
    await s.data.addPack(
      beanId: other.id,
      roastDate: DateTime.utc(2026, 11, 1),
      sizeG: 250,
    );
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    expect(find.byKey(const Key('hint-purge')), findsNothing);
    await tester.tap(find.byKey(const Key('field-pack')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Santos').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Grind and discard 2.5 g first (bean change)'),
      findsOneWidget,
    );
    expect(fieldText(tester, 'purge'), '2.5');
  });

  testWidgets('AC3 purge banner when the grinder was idle for 24 h', (
    tester,
  ) async {
    final s = await seedBrewData();
    await s.brew(at: DateTime.utc(2026, 11, 15, 11));
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    expect(
      find.text('Grind and discard 2.5 g first (grinder idle)'),
      findsOneWidget,
    );
    expect(fieldText(tester, 'purge'), '2.5');
  });

  testWidgets('no purge banner when the grinder was used 23 h ago', (
    tester,
  ) async {
    final s = await seedBrewData();
    await s.brew(at: DateTime.utc(2026, 11, 15, 13));
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    expect(find.byKey(const Key('hint-purge')), findsNothing);
    expect(fieldText(tester, 'purge'), '0');
  });

  testWidgets('AC4 timer writes seconds into the field and stays editable', (
    tester,
  ) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    final toggle = find.byKey(const Key('timer-toggle'));
    await tester.ensureVisible(toggle);
    expect(find.text('Start timer'), findsOneWidget);
    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(seconds: 27));
    expect(fieldText(tester, 'shot'), '27');
    expect(find.text('0:27'), findsOneWidget);
    expect(find.text('Stop timer'), findsOneWidget);
    await tester.tap(toggle);
    await tester.pump();
    expect(find.text('Start timer'), findsOneWidget);
    expect(fieldText(tester, 'shot'), '27');
    await enterField(tester, 'shot', '30');
    expect(fieldText(tester, 'shot'), '30');
  });

  testWidgets('grind stepper moves by one scale step and stops at the ends', (
    tester,
  ) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    expect(fieldText(tester, 'grind'), '15.0');
    await tester.tap(find.byKey(const Key('grind-minus')));
    await tester.pump();
    expect(fieldText(tester, 'grind'), '14.5');
    await tester.tap(find.byKey(const Key('grind-plus')));
    await tester.pump();
    expect(fieldText(tester, 'grind'), '15.0');
    await enterField(tester, 'grind', '1');
    await tester.tap(find.byKey(const Key('grind-minus')));
    await tester.pump();
    expect(fieldText(tester, 'grind'), '1.0');
    await enterField(tester, 'grind', '30');
    await tester.tap(find.byKey(const Key('grind-plus')));
    await tester.pump();
    expect(fieldText(tester, 'grind'), '30.0');
    await tester.tap(find.byKey(const Key('grind-minus')));
    await tester.pump();
    expect(fieldText(tester, 'grind'), '29.5');
  });

  testWidgets('taste chips and stars are chosen and cleared by a second tap', (
    tester,
  ) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    await enterField(tester, 'grind', '12');
    await enterField(tester, 'dose', '18');
    await enterField(tester, 'yield', '36');
    await enterField(tester, 'shot', '27');
    await tapKey(tester, 'taste-sour');
    await tapKey(tester, 'taste-sour');
    await tapKey(tester, 'taste-bitter');
    await tapKey(tester, 'rating-4');
    await tapKey(tester, 'rating-5');
    await tapKey(tester, 'rating-5');
    await tapKey(tester, 'rating-3');
    await tapKey(tester, 'form-save');
    final brew = s.data.brews.single;
    expect(brew.taste?.name, 'bitter');
    expect(brew.rating, 3);
    expect(brew.waterProfileId, s.water.id);
  });

  testWidgets('saving without machine, grinder and pack explains why', (
    tester,
  ) async {
    final data = await loadTestAppData();
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/brews/new');
    await tapKey(tester, 'form-save');
    expect(find.text('Choose machine, grinder and pack'), findsOneWidget);
    expect(data.brews, isEmpty);
  });

  testWidgets('a missing brew shows the not-found message', (tester) async {
    final data = await loadTestAppData();
    await pumpApp(tester, data: data);
    await goTo(tester, '/brews/detail');
    expect(find.text('Brew not found'), findsOneWidget);
  });
}
