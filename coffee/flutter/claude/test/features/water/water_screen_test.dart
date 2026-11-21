import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/core/theme/app_colors.dart';
import 'package:kaffee_begleiter/features/water/presentation/water_bar_painter.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';

Future<void> addTapWater(WidgetTester tester) async {
  await goTo(tester, '/water');
  await tapKey(tester, 'action-add');
  await enterField(tester, 'name', 'Tap');
  await enterField(tester, 'hardness', '30');
  await tapKey(tester, 'form-save');
}

WaterBarPainter painterOf(WidgetTester tester, String param) =>
    tester.widget<CustomPaint>(find.byKey(Key('bar-paint-$param'))).painter!
        as WaterBarPainter;

void main() {
  late AppData data;
  setUp(() async => data = await loadTestAppData());

  for (final lang in ['en', 'de']) {
    testWidgets('AC4 empty water state in $lang', (tester) async {
      final de = lang == 'de';
      await pumpApp(tester, data: data, locale: Locale(lang));
      await goTo(tester, '/water');
      expect(
        find.text(de ? 'Noch kein Wasserprofil' : 'No water profile yet'),
        findsOneWidget,
      );
      expect(
        find.text(
          de
              ? 'Erfasse die Härte deines Wassers.'
              : "Enter your water's hardness.",
        ),
        findsOneWidget,
      );
      expect(
        find.text(de ? 'Wasserprofil hinzufügen' : 'Add water profile'),
        findsWidgets,
      );
    });
  }

  testWidgets('AC7 30 fH is outside SCA, hint, bars and unit switch', (
    tester,
  ) async {
    await pumpApp(tester, data: data, height: tallViewport);
    await addTapWater(tester);
    expect(data.waterProfiles.single.hardnessPpm, 300);
    expect(find.text('Tap'), findsOneWidget);
    expect(find.text('30.0 °fH'), findsOneWidget);
    expect(find.text('Outside SCA'), findsOneWidget);

    await tester.tap(find.text('Tap'));
    await tester.pumpAndSettle();
    expect(
      find.text('Check water first: hardness 300 ppm, SCA 50–175 ppm'),
      findsOneWidget,
    );
    expect(find.text('1 of 6 measured'), findsOneWidget);
    expect(find.text('not measured'), findsNWidgets(5));
    for (final p in [
      'tds',
      'hardness',
      'alkalinity',
      'ph',
      'sodium',
      'chlorine',
    ]) {
      expect(find.byKey(Key('bar-paint-$p')), findsOneWidget);
    }
    expect(painterOf(tester, 'hardness').fillColor, AppColors.light.error);
    expect(painterOf(tester, 'hardness').rangeStart, closeTo(50 / 400, 1e-9));
    expect(painterOf(tester, 'tds').valueFraction, 0);

    await goTo(tester, '/settings');
    await tapKey(tester, 'hardness-unit-ppm');
    await goTo(tester, '/water');
    expect(find.text('300 ppm'), findsOneWidget);
    expect(find.text('30.0 °fH'), findsNothing);
  });

  testWidgets('German hint, chip and measured count', (tester) async {
    await pumpApp(
      tester,
      data: data,
      locale: const Locale('de'),
      height: tallViewport,
    );
    await addTapWater(tester);
    expect(find.text('Ausserhalb SCA'), findsOneWidget);
    await tester.tap(find.text('Tap'));
    await tester.pumpAndSettle();
    expect(
      find.text('Wasser zuerst prüfen: Härte 300 ppm, SCA 50–175 ppm'),
      findsOneWidget,
    );
    expect(find.text('1 von 6 gemessen'), findsOneWidget);
    expect(find.text('nicht gemessen'), findsNWidgets(5));
  });

  testWidgets('15 fH is in SCA range and its bar is not error coloured', (
    tester,
  ) async {
    await data.addWaterProfile(name: 'Soft', hardnessPpm: 150);
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/water');
    expect(find.text('15.0 °fH'), findsOneWidget);
    expect(find.text('In SCA range'), findsOneWidget);
    await tester.tap(find.text('Soft'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Check water first'), findsNothing);
    expect(painterOf(tester, 'hardness').fillColor, AppColors.light.success);
  });

  testWidgets('dark theme uses dark error colour for out of range', (
    tester,
  ) async {
    await data.addWaterProfile(name: 'Hard', hardnessPpm: 300);
    await pumpApp(
      tester,
      data: data,
      brightness: Brightness.dark,
      height: tallViewport,
    );
    await goTo(tester, '/water');
    await tester.tap(find.text('Hard'));
    await tester.pumpAndSettle();
    expect(painterOf(tester, 'hardness').fillColor, AppColors.dark.error);
  });

  testWidgets('AC10 deleting a water profile removes it', (tester) async {
    final w = await data.addWaterProfile(name: 'Tap', hardnessPpm: 300);
    await pumpApp(tester, data: data);
    await goTo(tester, '/water');
    await tester.tap(find.text('Tap'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('action-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Tap'), findsNothing);
    expect(find.text('No water profile yet'), findsOneWidget);
    expect(data.waterProfileById(w.id)!.isDeleted, isTrue);
  });
}
