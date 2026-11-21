import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/care/domain/care_kind.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';
import '../brews/brew_test_helpers.dart';

void main() {
  testWidgets('UC7: backflush shows Due, after Done In 7 days', (tester) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/care');
    final id = 'backflush-${s.machine.id}';
    expect(tester.widget<Text>(find.byKey(Key('care-status-$id'))).data, 'Due');
    expect(find.text('The machine manual takes precedence.'), findsWidgets);
    await tapKey(tester, 'care-done-$id');
    expect(
      tester.widget<Text>(find.byKey(Key('care-status-$id'))).data,
      'In 7 days',
    );
    final task = s.data.careTasks.firstWhere(
      (t) => t.kind == CareKind.backflush,
    );
    expect(task.daysLeft, 7);
  });

  testWidgets('shots since last time are shown', (tester) async {
    final s = await seedBrewData();
    await s.brew();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/care');
    expect(find.text('Shots since last time: 1'), findsWidgets);
  });

  for (final (locale, title) in [
    (const Locale('en'), 'Nothing to maintain'),
    (const Locale('de'), 'Nichts zu pflegen'),
  ]) {
    testWidgets('empty state in $locale', (tester) async {
      await pumpApp(tester, data: await loadTestAppData(), locale: locale);
      await goTo(tester, '/care');
      expect(find.text(title), findsOneWidget);
    });
  }
}
