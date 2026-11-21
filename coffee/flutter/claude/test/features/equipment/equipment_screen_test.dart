import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';

void main() {
  testWidgets('AC1 adding grinder M1 shows card with 2.5 g and scale', (
    tester,
  ) async {
    final data = await loadTestAppData();
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/equipment');
    await tapKey(tester, 'action-add');
    await enterField(tester, 'name', 'M1');
    await enterField(tester, 'min', '1');
    await enterField(tester, 'max', '30');
    await enterField(tester, 'step', '0.5');
    await enterField(tester, 'dead', '2,5');
    await tapKey(tester, 'form-save');
    expect(find.text('M1'), findsOneWidget);
    expect(find.text('2.5 g'), findsOneWidget);
    expect(find.text('1–30 · 0.5'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    final g = data.grinders.single;
    expect(
      (g.scaleMin, g.scaleMax, g.scaleStep, g.deadSpaceG),
      (1, 30, 0.5, 2.5),
    );
    expect(g.finerDirection, FinerDirection.down);
    final card = find.byKey(Key('grinder-${g.id}'));
    expect(tester.getSize(card).height, 88);
  });

  testWidgets('grinder card is editable and direction is stored', (
    tester,
  ) async {
    final data = await loadTestAppData();
    await data.addGrinder(
      name: 'M1',
      scaleMin: 1,
      scaleMax: 30,
      scaleStep: 0.5,
      finerDirection: FinerDirection.down,
      deadSpaceG: 2.5,
    );
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/equipment');
    await tester.tap(find.text('M1'));
    await tester.pumpAndSettle();
    expect(find.text('Edit grinder'), findsOneWidget);
    await enterField(tester, 'name', 'M2');
    await tapKey(tester, 'direction-up');
    await tapKey(tester, 'form-save');
    expect(find.text('M2'), findsOneWidget);
    expect(data.grinders.single.finerDirection, FinerDirection.up);
  });

  testWidgets('grinder form shows validation errors', (tester) async {
    await pumpApp(tester, data: await loadTestAppData(), height: tallViewport);
    await goTo(tester, '/equipment/grinder/new');
    await enterField(tester, 'max', '1');
    await enterField(tester, 'min', '5');
    await enterField(tester, 'step', '0');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a name'), findsOneWidget);
    expect(
      find.text('Maximum must be greater than the minimum'),
      findsOneWidget,
    );
    expect(find.text('Step must be greater than 0'), findsOneWidget);
    expect(find.text('Enter a value between 0 and 100'), findsOneWidget);
  });

  testWidgets('AC3 machine form creates a card with a due backflush', (
    tester,
  ) async {
    final data = await loadTestAppData();
    final water = await data.addWaterProfile(name: 'Tap', hardnessPpm: 150);
    await pumpApp(
      tester,
      data: data,
      locale: const Locale('de'),
      height: tallViewport,
    );
    await goTo(tester, '/equipment');
    await tester.tap(find.byKey(const Key('tab-machines')));
    await tester.pumpAndSettle();
    await tapKey(tester, 'action-add');
    await enterField(tester, 'name', 'Gaggia');
    await enterField(tester, 'temp', '93');
    await enterField(tester, 'pre', '8');
    await enterField(tester, 'profile', 'flat 9 bar');
    await tester.tap(find.byKey(const Key('field-water')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tap').last);
    await tester.pumpAndSettle();
    await tapKey(tester, 'form-save');
    expect(find.text('Gaggia'), findsOneWidget);
    expect(find.text('93 °C · 8 s'), findsOneWidget);
    expect(find.text('Backflush: Fällig'), findsOneWidget);
    expect(find.text('7 Tage'), findsNothing);
    expect(data.machines.single.defaultWaterProfileId, water.id);
  });

  testWidgets('machine form validates and edits', (tester) async {
    final data = await loadTestAppData();
    await data.addMachine(
      name: 'Gaggia',
      brewTempC: 93,
      preinfusionS: 8,
      pressureProfile: '',
    );
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/equipment');
    await tester.tap(find.byKey(const Key('tab-machines')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gaggia'));
    await tester.pumpAndSettle();
    expect(find.text('Edit machine'), findsOneWidget);
    await enterField(tester, 'temp', '500');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a value between 60 and 110'), findsOneWidget);
    await enterField(tester, 'temp', '94.5');
    await tapKey(tester, 'form-save');
    expect(find.text('94.5 °C · 8 s'), findsOneWidget);
  });

  for (final lang in ['en', 'de']) {
    testWidgets('AC4 empty states in $lang', (tester) async {
      final de = lang == 'de';
      await pumpApp(
        tester,
        data: await loadTestAppData(),
        locale: Locale(lang),
      );
      await goTo(tester, '/equipment');
      expect(
        find.text(de ? 'Noch keine Mühle' : 'No grinder yet'),
        findsOneWidget,
      );
      expect(
        find.text(
          de
              ? 'Lege deine Mühle mit Skala und Totraum an.'
              : 'Add your grinder with scale and dead space.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(de ? 'Mühle hinzufügen' : 'Add grinder'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('tab-machines')));
      await tester.pumpAndSettle();
      expect(
        find.text(de ? 'Noch keine Maschine' : 'No machine yet'),
        findsOneWidget,
      );
      expect(
        find.text(
          de
              ? 'Lege deine Maschine mit Einstellungen an.'
              : 'Add your machine with its settings.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(de ? 'Maschine hinzufügen' : 'Add machine'),
        findsOneWidget,
      );
    });
  }

  testWidgets('AC10 deleted grinder and machine vanish from the lists', (
    tester,
  ) async {
    final data = await loadTestAppData();
    final g = await data.addGrinder(
      name: 'M1',
      scaleMin: 1,
      scaleMax: 30,
      scaleStep: 0.5,
      finerDirection: FinerDirection.down,
      deadSpaceG: 2.5,
    );
    await data.addMachine(
      name: 'Gaggia',
      brewTempC: 93,
      preinfusionS: 8,
      pressureProfile: '',
    );
    await pumpApp(tester, data: data);
    await goTo(tester, '/equipment');
    await tester.tap(find.byKey(const Key('action-delete')));
    await tester.pumpAndSettle();
    expect(find.text('M1'), findsNothing);
    expect(find.text('No grinder yet'), findsOneWidget);
    expect(data.grinderById(g.id), isNotNull);
    await tester.tap(find.byKey(const Key('tab-machines')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('action-delete')));
    await tester.pumpAndSettle();
    expect(find.text('No machine yet'), findsOneWidget);
  });

  testWidgets('delete buttons carry a semantic label', (tester) async {
    final data = await loadTestAppData();
    await data.addGrinder(
      name: 'M1',
      scaleMin: 1,
      scaleMax: 30,
      scaleStep: 0.5,
      finerDirection: FinerDirection.down,
      deadSpaceG: 2.5,
    );
    await pumpApp(tester, data: data);
    await goTo(tester, '/equipment');
    expect(find.bySemanticsLabel('Delete M1'), findsWidgets);
    final size = tester.getSize(find.byKey(const Key('action-delete')));
    expect(size.width >= 48 && size.height >= 48, isTrue);
  });
}
