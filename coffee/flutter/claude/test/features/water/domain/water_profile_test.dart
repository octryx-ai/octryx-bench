import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/water/domain/water_profile.dart';

void main() {
  final t = DateTime.utc(2026, 11, 16);
  final p = WaterProfile(
    id: 'w',
    createdAt: t,
    updatedAt: t,
    name: 'Tap',
    hardnessPpm: 150,
    ph: 7,
    sodiumMgL: 5,
  );
  test('json round trip', () {
    expect(WaterProfile.fromJson(p.toJson()).toJson(), p.toJson());
    expect(p.toJson()['tdsPpm'], isNull);
  });
  test('copyWith keeps, replaces and clears optionals', () {
    expect(p.copyWith(name: 'X').ph, 7);
    expect(p.copyWith(ph: 7.2).ph, 7.2);
    expect(p.copyWith(ph: null).ph, isNull);
    expect(p.copyWith(ph: null).sodiumMgL, 5);
    expect(p.copyWith(hardnessPpm: 100).hardnessPpm, 100);
  });
}
