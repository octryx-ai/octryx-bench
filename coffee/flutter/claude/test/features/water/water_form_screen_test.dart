import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/features/settings/domain/hardness_unit.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';

void main() {
  late AppData data;
  setUp(() async => data = await loadTestAppData());

  testWidgets('AC8 empty form shows name and hardness errors (en)', (
    tester,
  ) async {
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/water/new');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Enter a value between 0 and 100'), findsOneWidget);
    expect(data.waterProfiles, isEmpty);
  });

  testWidgets('AC8 empty form shows errors in German', (tester) async {
    await pumpApp(
      tester,
      data: data,
      locale: const Locale('de'),
      height: tallViewport,
    );
    await goTo(tester, '/water/new');
    await tapKey(tester, 'form-save');
    expect(find.text('Name eingeben'), findsOneWidget);
    expect(find.text('Wert zwischen 0 und 100 eingeben'), findsOneWidget);
  });

  testWidgets('AC8 range errors per field and long names', (tester) async {
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/water/new');
    await enterField(tester, 'name', 'x' * 61);
    await enterField(tester, 'hardness', '101');
    await enterField(tester, 'alkalinity', '501');
    await enterField(tester, 'tds', '1001');
    await enterField(tester, 'ph', '15');
    await enterField(tester, 'sodium', '501');
    await enterField(tester, 'chlorine', '11');
    await tapKey(tester, 'form-save');
    expect(find.text('Use at most 60 characters'), findsOneWidget);
    expect(find.text('Enter a value between 0 and 100'), findsOneWidget);
    expect(find.text('Enter a value between 0 and 500'), findsNWidgets(2));
    expect(find.text('Enter a value between 0 and 1000'), findsOneWidget);
    expect(find.text('Enter a value between 0 and 14'), findsOneWidget);
    expect(find.text('Enter a value between 0 and 10'), findsOneWidget);
    expect(data.waterProfiles, isEmpty);
  });

  testWidgets('hardness bounds follow the unit and convert on switch', (
    tester,
  ) async {
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/water/new');
    await enterField(tester, 'hardness', '15');
    await tapKey(tester, 'unit-ppm');
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('field-hardness')),
        matching: find.byType(TextField),
      ),
    );
    expect(field.controller!.text, '150');
    await enterField(tester, 'hardness', '1001');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a value between 0 and 1000'), findsOneWidget);
    await tapKey(tester, 'unit-dH');
    await enterField(tester, 'hardness', '57');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a value between 0 and 56'), findsOneWidget);
  });

  testWidgets('optional fields stay empty and comma decimals are accepted', (
    tester,
  ) async {
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/water');
    await tapKey(tester, 'action-add');
    await tapKey(tester, 'unit-dH');
    await enterField(tester, 'name', 'Well');
    await enterField(tester, 'hardness', '8,4');
    await enterField(tester, 'ph', '7,2');
    await tapKey(tester, 'form-save');
    final w = data.waterProfiles.single;
    expect(w.hardnessPpm, closeTo(8.4 * 17.848, 1e-9));
    expect(w.ph, 7.2);
    expect(w.tdsPpm, isNull);
    expect(w.chlorineMgL, isNull);
    await tester.tap(find.text('Well'));
    await tester.pumpAndSettle();
    expect(find.text('not measured'), findsNWidgets(4));
    expect(find.text('1 of 6 measured'), findsNothing);
    expect(find.text('2 of 6 measured'), findsOneWidget);
  });

  testWidgets('editing prefills in the selected unit and saves', (
    tester,
  ) async {
    final w = await data.addWaterProfile(
      name: 'Tap',
      hardnessPpm: 300,
      tdsPpm: 200,
    );
    await data.setHardnessUnit(HardnessUnit.ppm);
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/water');
    await tester.tap(find.text('Tap'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'action-edit');
    expect(find.text('Edit water profile'), findsOneWidget);
    await enterField(tester, 'hardness', '120');
    await enterField(tester, 'tds', '');
    await tapKey(tester, 'form-save');
    final saved = data.waterProfileById(w.id)!;
    expect(saved.hardnessPpm, 120);
    expect(saved.tdsPpm, isNull);
    expect(find.text('120 ppm'), findsWidgets);
  });
}
