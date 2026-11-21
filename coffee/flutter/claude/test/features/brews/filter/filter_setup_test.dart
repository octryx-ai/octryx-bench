import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/widgets/app_button.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/test_app_data.dart';
import '../../../form_helpers.dart';
import '../../beans/bean_test_helpers.dart';
import '../brew_test_helpers.dart';
import 'filter_test_helpers.dart';

void main() {
  Slider slider(WidgetTester t) =>
      t.widget<Slider>(find.byKey(const Key('filter-ratio')));

  String text(WidgetTester t, String key) =>
      t.widget<Text>(find.byKey(Key(key))).data!;

  testWidgets('AC2 slider runs 1:14 to 1:18 in 0.5 steps, default 1:16', (
    tester,
  ) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    final sl = slider(tester);
    expect(sl.min, 14);
    expect(sl.max, 18);
    expect(sl.divisions, 8);
    expect(sl.value, 16);
    expect(text(tester, 'filter-ratio-value'), '1:16');
    expect(text(tester, 'filter-water-total'), 'Total water: 320 g');
  });

  testWidgets('AC2 water total follows dose and ratio (15 g at 1:15)', (
    tester,
  ) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await enterField(tester, 'dose', '15');
    tester.widget<Slider>(find.byKey(const Key('filter-ratio'))).onChanged!(15);
    await tester.pump();
    expect(text(tester, 'filter-ratio-value'), '1:15');
    expect(text(tester, 'filter-water-total'), 'Total water: 225 g');
    tester.widget<Slider>(find.byKey(const Key('filter-ratio'))).onChanged!(
      15.3,
    );
    await tester.pump();
    expect(text(tester, 'filter-ratio-value'), '1:15.5');
    expect(text(tester, 'filter-water-total'), 'Total water: 233 g');
  });

  testWidgets('AC2 water total in German', (tester) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data, locale: const Locale('de'));
    expect(find.text('Guided filter'), findsNothing);
    expect(find.text('Filter geführt'), findsOneWidget);
    expect(text(tester, 'filter-water-total'), 'Wasser gesamt: 320 g');
  });

  testWidgets('all five methods are selectable; non-V60 shows the note', (
    tester,
  ) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    expect(find.byKey(const Key('filter-method-note')), findsNothing);
    for (final m in BrewMethod.values.where((m) => m.isFilter)) {
      await tester.tap(find.byKey(Key('method-${m.name}')));
      await tester.pump();
      final chips = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.byKey(Key('method-${m.name}')),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(chips.properties.selected, isTrue, reason: m.name);
      expect(
        find.byKey(const Key('filter-method-note')),
        m == BrewMethod.v60 ? findsNothing : findsOneWidget,
      );
    }
    expect(find.text('V60 scheme'), findsOneWidget);
    expect(find.text('Default without source'), findsOneWidget);
    expect(find.byKey(const Key('method-espresso')), findsNothing);
  });

  testWidgets('setup has one filled Start button and a Cancel', (tester) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    expect(find.byType(AppButton), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Guided filter'), findsOneWidget);
  });

  testWidgets('no grinder shows the hint; no pack disables Start', (
    tester,
  ) async {
    final data = await loadTestAppData();
    await pumpFilter(tester, data);
    expect(find.text('Add a grinder first'), findsOneWidget);
    expect(find.text('No pack is ready yet'), findsOneWidget);
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
  });

  testWidgets('AC7 packs: resting and too-old are excluded', (tester) async {
    final s = await seedFilterData(roasts: ['2026-11-04']);
    await seedBean(
      s.data,
      'Resting',
      kind: BeanKind.filter,
      roasts: ['2026-11-14'],
    );
    await seedBean(
      s.data,
      'Stale',
      kind: BeanKind.filter,
      roasts: ['2026-09-01'],
    );
    await pumpFilter(tester, s.data);
    await tester.tap(find.byKey(const Key('field-pack')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ethiopia'), findsWidgets);
    expect(find.textContaining('Resting'), findsNothing);
    expect(find.textContaining('Stale'), findsNothing);
    expect(find.textContaining('Kenya AA'), findsNothing);
    expect(find.textContaining('backup'), findsNothing);
  });

  testWidgets('AC7 a blend is offered as backup only if nothing else is', (
    tester,
  ) async {
    final s = await seedBrewData();
    await pumpFilter(tester, s.data);
    expect(find.text('No pack is ready yet'), findsNothing);
    expect(find.textContaining('Kenya AA'), findsWidgets);
    expect(find.textContaining('(backup)'), findsWidgets);
    expect(
      tester.widget<AppButton>(find.byType(AppButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('invalid dose and grind show errors and do not start', (
    tester,
  ) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await enterField(tester, 'dose', '41');
    await enterField(tester, 'grind', '12.3');
    await tester.tap(find.byKey(const Key('form-save')));
    await tester.pump();
    expect(find.text('Enter a value between 5 and 40'), findsOneWidget);
    expect(find.textContaining("not on the grinder's scale"), findsOneWidget);
    expect(find.byKey(const Key('focus-timer')), findsNothing);
  });
}
