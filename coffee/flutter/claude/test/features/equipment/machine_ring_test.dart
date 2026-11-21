import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/theme/app_colors.dart';
import 'package:kaffee_begleiter/features/equipment/presentation/machine_ring.dart';

void main() {
  test('ring colour follows remaining days', () {
    const c = AppColors.light;
    expect(MachineRing.colorFor(c, 7), c.success);
    expect(MachineRing.colorFor(c, 3), c.success);
    expect(MachineRing.colorFor(c, 2), c.warning);
    expect(MachineRing.colorFor(c, 1), c.warning);
    expect(MachineRing.colorFor(c, 0), c.error);
    expect(MachineRing.colorFor(c, -2), c.error);
  });
}
