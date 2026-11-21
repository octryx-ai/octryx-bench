import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';
import 'package:kaffee_begleiter/features/equipment/domain/grinder.dart';
import 'package:kaffee_begleiter/features/equipment/domain/grinder_scale.dart';
import 'package:kaffee_begleiter/features/equipment/domain/machine.dart';

final _t = DateTime.utc(2026, 11, 16, 8, 30, 0, 123);

Grinder _grinder() => Grinder(
  id: 'g1',
  createdAt: _t,
  updatedAt: _t,
  name: 'Niche',
  scaleMin: 1,
  scaleMax: 30,
  scaleStep: 0.5,
  finerDirection: FinerDirection.down,
  deadSpaceG: 0.5,
);

void main() {
  group('GrinderScale.validate (scale 1-30, step 0.5)', () {
    final g = _grinder();
    test('accepts valid values', () {
      for (final v in [1.0, 12.5, 13.0, 30.0, 29.5]) {
        expect(GrinderScale.validate(g, v), isNull, reason: '$v');
      }
    });
    test('rejects out of range', () {
      expect(GrinderScale.validate(g, 0.5), GrindSettingError.outOfRange);
      expect(GrinderScale.validate(g, 30.5), GrindSettingError.outOfRange);
    });
    test('rejects off-step values', () {
      expect(GrinderScale.validate(g, 12.3), GrindSettingError.notOnStep);
      expect(GrinderScale.validate(g, 1.25), GrindSettingError.notOnStep);
    });
    test('is floating-point safe with step 0.1', () {
      final f = g.copyWith(scaleMin: 0, scaleMax: 10, scaleStep: 0.1);
      expect(GrinderScale.validate(f, 0.3), isNull);
      expect(GrinderScale.validate(f, 2.7), isNull);
      expect(GrinderScale.validate(f, 0.35), GrindSettingError.notOnStep);
    });
  });

  group('Grinder', () {
    test('json round trip', () {
      final g = _grinder();
      final back = Grinder.fromJson(g.toJson());
      expect(back.toJson(), g.toJson());
      expect(g.toJson()['createdAt'], '2026-11-16T08:30:00.123Z');
      expect(back.finerDirection, FinerDirection.down);
    });
    test('copyWith keeps unchanged fields', () {
      final g = _grinder().copyWith(name: 'Eureka');
      expect(g.name, 'Eureka');
      expect(g.scaleMax, 30);
      expect(g.id, 'g1');
    });
    test('copyWithBase sets deletedAt', () {
      final g = _grinder().copyWithBase(deletedAt: _t, updatedAt: _t);
      expect(g.isDeleted, isTrue);
    });
  });

  group('Machine', () {
    final m = Machine(
      id: 'm1',
      createdAt: _t,
      updatedAt: _t,
      name: 'Gaggia',
      brewTempC: 93,
      preinfusionS: 5,
      pressureProfile: 'flat 9 bar',
      defaultWaterProfileId: 'w1',
    );
    test('json round trip', () {
      expect(Machine.fromJson(m.toJson()).toJson(), m.toJson());
    });
    test('copyWith can clear default water profile', () {
      expect(m.copyWith(name: 'X').defaultWaterProfileId, 'w1');
      expect(
        m.copyWith(clearDefaultWaterProfile: true).defaultWaterProfileId,
        isNull,
      );
    });
  });
}
