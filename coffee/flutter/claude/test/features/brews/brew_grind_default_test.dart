import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../form_helpers.dart';
import '../../helpers.dart';
import 'brew_test_helpers.dart';

void main() {
  testWidgets('OE-72_grind_starts_at_15', (tester) async {
    final s = await seedBrewData();
    await pumpApp(tester, data: s.data, height: tallViewport);
    await goTo(tester, '/brews/new');
    final field = find.descendant(
      of: find.byKey(const Key('field-grind')),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(field).controller!.text, '15.0');
  });
}
