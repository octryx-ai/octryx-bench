import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';
import 'package:kaffee_begleiter/features/equipment/domain/grinder.dart';
import 'package:kaffee_begleiter/features/equipment/presentation/grind_setting_error.dart';
import 'package:kaffee_begleiter/l10n/app_localizations_de.dart';
import 'package:kaffee_begleiter/l10n/app_localizations_en.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';
import '../../helpers.dart';

void main() {
  final epoch = DateTime.utc(2026);
  final grinder = Grinder(
    id: 'g',
    createdAt: epoch,
    updatedAt: epoch,
    name: 'M1',
    scaleMin: 1,
    scaleMax: 30,
    scaleStep: 0.5,
    finerDirection: FinerDirection.down,
    deadSpaceG: 2.5,
  );

  test('grindSettingErrorText returns the spec texts', () {
    final en = AppLocalizationsEn();
    final de = AppLocalizationsDe();
    expect(grindSettingErrorText(en, grinder, 12.5), isNull);
    expect(
      grindSettingErrorText(en, grinder, 12.3),
      "Value is not on the grinder's scale (step 0.5)",
    );
    expect(
      grindSettingErrorText(de, grinder, 31),
      'Wert liegt nicht auf der Skala der Mühle (Schritt 0.5)',
    );
    expect(
      grindSettingErrorText(en, grinder, 0.5),
      "Value is not on the grinder's scale (step 0.5)",
    );
  });

  for (final (lang, text) in [
    ('en', "Value is not on the grinder's scale (step 0.5)"),
    ('de', 'Wert liegt nicht auf der Skala der Mühle (Schritt 0.5)'),
  ]) {
    testWidgets('AC2 form check field flags 12.3 and 31 in $lang', (
      tester,
    ) async {
      await pumpApp(
        tester,
        data: await loadTestAppData(),
        locale: Locale(lang),
        height: tallViewport,
      );
      await goTo(tester, '/equipment/grinder/new');
      await enterField(tester, 'min', '1');
      await enterField(tester, 'max', '30');
      await enterField(tester, 'step', '0.5');
      await enterField(tester, 'check', '12,3');
      expect(find.text(text), findsOneWidget);
      await enterField(tester, 'check', '31');
      expect(find.text(text), findsOneWidget);
      await enterField(tester, 'check', '12.5');
      expect(find.text(text), findsNothing);
    });
  }
}
