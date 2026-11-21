import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';
import 'package:kaffee_begleiter/features/beans/presentation/pack_form_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';

void main() {
  for (final (locale, title, hint) in [
    (const Locale('en'), 'No pack yet', 'Add a pack'),
    (const Locale('de'), 'Ohne Packung', 'Packung hinzufügen'),
  ]) {
    testWidgets('a bean without a pack is listed under "$title" in $locale', (
      tester,
    ) async {
      final data = await loadTestAppData();
      final bean = await data.addBean(
        name: 'Bohne 1',
        roaster: 'Roestwerk',
        roastLevel: RoastLevel.medium,
        kind: BeanKind.allround,
      );
      await pumpApp(tester, data: data, height: tallViewport, locale: locale);
      expect(find.text(title), findsOneWidget);
      expect(find.text(hint), findsOneWidget);
      expect(find.byKey(Key('today-no-pack-${bean.id}')), findsOneWidget);
      expect(find.text('Bohne 1'), findsOneWidget);
      expect(find.byKey(const Key('today-ready-none')), findsOneWidget);
    });
  }

  testWidgets('a bean with a live pack is not listed under Ohne Packung', (
    tester,
  ) async {
    final data = await loadTestAppData();
    final bean = await data.addBean(
      name: 'Bohne 1',
      roaster: 'Roestwerk',
      roastLevel: RoastLevel.medium,
      kind: BeanKind.allround,
    );
    await data.addPack(beanId: bean.id, roastDate: data.today, sizeG: 250);
    await pumpApp(tester, data: data, height: tallViewport);
    expect(find.text('No pack yet'), findsNothing);
    expect(find.text('Add a pack'), findsNothing);
  });

  testWidgets('no bean at all shows the empty state, not the group', (
    tester,
  ) async {
    await pumpApp(tester, data: await loadTestAppData(), height: tallViewport);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('No pack yet'), findsNothing);
  });

  testWidgets('tapping the row opens the pack form of that bean', (
    tester,
  ) async {
    final data = await loadTestAppData();
    final bean = await data.addBean(
      name: 'Bohne 1',
      roaster: 'Roestwerk',
      roastLevel: RoastLevel.medium,
      kind: BeanKind.allround,
    );
    await pumpApp(tester, data: data, height: tallViewport);
    await tapKey(tester, 'today-no-pack-${bean.id}');
    expect(find.byType(PackFormScreen), findsOneWidget);
  });
}
