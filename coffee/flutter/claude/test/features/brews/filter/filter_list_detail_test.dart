import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/presentation/filter/filter_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../form_helpers.dart';
import '../../../helpers.dart';
import '../brew_test_helpers.dart';
import 'filter_test_helpers.dart';

void main() {
  String sentence(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('rec-sentence'))).data!;

  testWidgets('AC8 list shows filter and espresso brews with their time', (
    tester,
  ) async {
    final s = await seedFilterData();
    final f = await filterBrew(s, rating: 4);
    final e = await s.brew(time: 27, at: DateTime.utc(2026, 11, 14));
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews');
    expect(
      tester.widget<Text>(find.byKey(Key('brew-time-${f.id}'))).data,
      '255 s',
    );
    expect(
      tester.widget<Text>(find.byKey(Key('brew-time-${e.id}'))).data,
      '27 s',
    );
    expect(find.text('V60'), findsOneWidget);
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('Ethiopia'), findsOneWidget);
    expect(find.text('★ 4'), findsOneWidget);
  });

  testWidgets('AC8 detail shows the filter values', (tester) async {
    final s = await seedFilterData();
    final f = await filterBrew(s);
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews');
    await tester.tap(find.byKey(Key('brew-${f.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Drawdown time'), findsOneWidget);
    expect(find.text('255 s'), findsOneWidget);
    expect(find.text('Total water'), findsOneWidget);
    expect(find.text('1:16.0'), findsOneWidget);
    expect(find.text('Bloom'), findsOneWidget);
    expect(find.text('Machine'), findsNothing);
    expect(find.text('Yield'), findsNothing);
    expect(find.textContaining('0:45 → 120 g'), findsOneWidget);
  });

  testWidgets('AC8 255 s bitter at 20.0 recommends grind 20.5 (DE too)', (
    tester,
  ) async {
    final s = await seedFilterData();
    final f = await filterBrew(s);
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews');
    await tester.tap(find.byKey(Key('brew-${f.id}')));
    await tester.pumpAndSettle();
    expect(sentence(tester), 'Set grind to 20.5');
    expect(find.textContaining('Drawdown 255 s is above'), findsOneWidget);
    expect(find.byKey(const Key('rec-source')), findsOneWidget);
  });

  testWidgets('AC8 German sentence reads Mahlgrad auf 20.5', (tester) async {
    final s = await seedFilterData();
    final f = await filterBrew(s);
    await pumpApp(
      tester,
      data: s.data,
      height: tallViewport,
      locale: const Locale('de'),
    );
    await goTo(tester, '/brews');
    await tester.tap(find.byKey(Key('brew-${f.id}')));
    await tester.pumpAndSettle();
    expect(sentence(tester), 'Mahlgrad auf 20.5');
    expect(find.textContaining('Abfluss 255 s liegt über'), findsOneWidget);
    expect(find.text('Abfluss-Zeit'), findsOneWidget);
  });

  testWidgets('AC8 Next try opens the filter setup prefilled', (tester) async {
    final s = await seedFilterData();
    final f = await filterBrew(s);
    await s.data.deleteBrew((await filterBrew(s, setting: 3)).id);
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews');
    await tester.tap(find.byKey(Key('brew-${f.id}')));
    await tester.pumpAndSettle();
    await tapKey(tester, 'next-try');
    expect(find.byType(FilterScreen), findsOneWidget);
    expect(fieldText(tester, 'grind'), '20.5');
    expect(fieldText(tester, 'dose'), '20');
    expect(
      tester.widget<Slider>(find.byKey(const Key('filter-ratio'))).value,
      16,
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('filter-water-total'))).data,
      'Total water: 320 g',
    );
    expect(f.method, BrewMethod.v60);
  });

  testWidgets('Next try of an espresso brew still opens the brew form', (
    tester,
  ) async {
    final s = await seedFilterData();
    final e = await s.brew();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews');
    await tester.tap(find.byKey(Key('brew-${e.id}')));
    await tester.pumpAndSettle();
    await tapKey(tester, 'next-try');
    expect(find.byType(FilterScreen), findsNothing);
    expect(find.text('Log a brew'), findsWidgets);
  });

  testWidgets('the full flow from Brew to a saved brew in the list', (
    tester,
  ) async {
    final s = await seedFilterData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews');
    await tapKey(tester, 'start-filter');
    await tester.tap(find.byKey(const Key('form-save')));
    await tester.pump();
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tapNext(tester);
    }
    await enterField(tester, 'drawdown', '190');
    await tester.tap(find.byKey(const Key('form-save')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('190 s'), findsOneWidget);
  });
}
