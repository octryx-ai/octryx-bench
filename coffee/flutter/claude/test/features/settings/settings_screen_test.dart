import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/settings/domain/hardness_unit.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';

void main() {
  testWidgets('AC9 hardness unit defaults to fH and is switchable', (
    tester,
  ) async {
    final data = await loadTestAppData();
    await pumpApp(tester, data: data);
    await goTo(tester, '/settings');
    expect(data.hardnessUnit, HardnessUnit.fH);
    expect(find.text('Hardness unit'), findsOneWidget);
    for (final unit in ['°fH', '°dH', 'ppm']) {
      expect(find.text(unit), findsOneWidget);
    }
    await tapKey(tester, 'hardness-unit-dH');
    expect(data.hardnessUnit, HardnessUnit.dH);
    await tapKey(tester, 'hardness-unit-ppm');
    expect(data.hardnessUnit, HardnessUnit.ppm);
  });

  testWidgets('export, import and style guide link are present (de)', (
    tester,
  ) async {
    await pumpApp(
      tester,
      data: await loadTestAppData(),
      locale: const Locale('de'),
      width: 1280,
    );
    await goTo(tester, '/settings');
    expect(find.text('Härteeinheit'), findsOneWidget);
    expect(find.byKey(const Key('settings-export')), findsOneWidget);
    expect(find.byKey(const Key('settings-import')), findsOneWidget);
    expect(find.byKey(const Key('link-/styleguide')), findsOneWidget);
    expect(find.text('Kommt bald'), findsWidgets);
  });
}
