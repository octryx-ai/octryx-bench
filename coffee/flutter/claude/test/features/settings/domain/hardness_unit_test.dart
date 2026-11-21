import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/settings/data/app_settings.dart';
import 'package:kaffee_begleiter/features/settings/domain/hardness_unit.dart';

void main() {
  test('15 fH is 150.0 ppm', () {
    expect(HardnessUnit.fH.toPpm(15), 150.0);
  });
  test('8.4 dH displays as 149.9 ppm', () {
    expect(HardnessUnit.dH.toPpm(8.4), closeTo(149.9232, 1e-9));
    expect(HardnessUnit.ppm.displayValue(HardnessUnit.dH.toPpm(8.4)), 149.9);
  });
  test('150 ppm is 15.0 fH and 8.4 dH', () {
    expect(HardnessUnit.fH.displayValue(150), 15.0);
    expect(HardnessUnit.dH.displayValue(150), 8.4);
    expect(HardnessUnit.ppm.displayValue(150), 150.0);
  });
  test('rounds half up', () {
    expect(HardnessUnit.fH.displayValue(12.5), 1.3);
    expect(HardnessUnit.fH.displayValue(12.4), 1.2);
  });
  test('code and parse', () {
    expect([for (final u in HardnessUnit.values) u.code], ['fH', 'dH', 'ppm']);
    for (final u in HardnessUnit.values) {
      expect(HardnessUnit.parse(u.code), u);
    }
    expect(() => HardnessUnit.parse('x'), throwsArgumentError);
  });
  test('settings default to fH', () {
    expect(const AppSettings().hardnessUnit, HardnessUnit.fH);
    expect(
      const AppSettings().copyWith(hardnessUnit: HardnessUnit.dH).hardnessUnit,
      HardnessUnit.dH,
    );
  });
}
