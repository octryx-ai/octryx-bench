import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/widgets/app_button.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';
import 'package:kaffee_begleiter/features/brews/presentation/brew_detail_screen.dart';
import 'package:kaffee_begleiter/features/brews/presentation/filter/filter_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../form_helpers.dart';
import '../brew_test_helpers.dart';
import 'filter_test_helpers.dart';

void main() {
  Future<void> toFinish(WidgetTester tester, {int seconds = 0}) async {
    await startFocus(tester);
    for (var i = 0; i < 4; i++) {
      if (i == 3 && seconds > 0) await tester.pump(Duration(seconds: seconds));
      await tapNext(tester);
    }
    await tester.pump();
  }

  testWidgets('AC5 drawdown is prefilled from the timer and editable', (
    tester,
  ) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await toFinish(tester, seconds: 181);
    expect(find.byType(FilterScreen), findsOneWidget);
    expect(find.text('Drawdown time (s)'), findsOneWidget);
    expect(fieldText(tester, 'drawdown'), '181');
    expect(find.byType(AppButton), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byKey(const Key('focus-timer')), findsNothing);
  });

  testWidgets('AC5 drawdown must be 1 to 600 s', (tester) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await toFinish(tester);
    for (final bad in ['0', '601', '']) {
      await enterField(tester, 'drawdown', bad);
      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pump();
      expect(find.text('Enter a value between 1 and 600'), findsOneWidget);
      expect(s.data.brews, isEmpty);
    }
    await enterField(tester, 'drawdown', '30');
    expect(find.text('Enter a value between 1 and 600'), findsNothing);
  });

  testWidgets('AC5 German error text', (tester) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data, locale: const Locale('de'));
    await toFinish(tester);
    await enterField(tester, 'drawdown', '601');
    await tester.tap(find.byKey(const Key('form-save')));
    await tester.pump();
    expect(find.text('Wert zwischen 1 und 600 eingeben'), findsOneWidget);
    expect(find.text('Abfluss-Zeit (s)'), findsOneWidget);
  });

  testWidgets('AC5 save logs the filter brew, deducts stock, opens detail', (
    tester,
  ) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await tester.tap(find.byKey(const Key('method-chemex')));
    await tester.pump();
    await toFinish(tester);
    await enterField(tester, 'drawdown', '195');
    await tester.tap(find.byKey(const Key('taste-balanced')));
    await tester.tap(find.byKey(const Key('rating-4')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('form-save')));
    await tester.pumpAndSettle();
    final brew = s.data.brews.single;
    expect(brew.method, BrewMethod.chemex);
    expect(brew.drawdownS, 195);
    expect(brew.doseG, 20);
    expect(brew.waterTotalG, 320);
    expect(brew.bloomG, 40);
    expect(brew.pours.map((p) => p.cumulativeG), [40, 120, 220, 320]);
    expect(brew.pours.map((p) => p.atS), [0, 45, 75, 120]);
    expect(brew.taste, Taste.balanced);
    expect(brew.rating, 4);
    expect(brew.machineId, isNull);
    expect(brew.shotTimeS, isNull);
    final pack = s.data.filterPackSuggestions().single.pack;
    expect(pack.remainingG, 230);
    expect(find.byType(BrewDetailScreen), findsOneWidget);
    expect(find.byType(FilterScreen), findsNothing);
    expect(find.text('195 s'), findsOneWidget);
    expect(find.text('320 g'), findsWidgets);
  });

  testWidgets('AC5 a pack with too little coffee shows the stock error', (
    tester,
  ) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await toFinish(tester);
    final pack = s.data.filterPackSuggestions().single.pack;
    await s.data.updatePack(pack.copyWith(remainingG: 12));
    await enterField(tester, 'drawdown', '200');
    await tester.tap(find.byKey(const Key('form-save')));
    await tester.pumpAndSettle();
    expect(
      find.text('Not enough beans in the pack (12 g left)'),
      findsOneWidget,
    );
    expect(s.data.brews, isEmpty);
    expect(find.byType(FilterScreen), findsOneWidget);
  });
}
