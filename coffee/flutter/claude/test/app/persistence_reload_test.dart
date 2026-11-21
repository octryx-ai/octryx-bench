import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';

/// OE-73: entries must survive a reload (a new [AppData] over the same
/// default storage), SPEC decision 2: local storage, offline first.
void main() {
  test('saved grinder survives reload', () async {
    final first = AppData();
    await first.addGrinder(
      name: 'M1',
      scaleMin: 1,
      scaleMax: 30,
      scaleStep: 1,
      finerDirection: FinerDirection.up,
      deadSpaceG: 2.5,
    );
    expect(first.grinders.map((g) => g.name), ['M1']);

    final reloaded = AppData();
    await reloaded.load();

    expect(reloaded.grinders.map((g) => g.name), ['M1']);
  });
}
