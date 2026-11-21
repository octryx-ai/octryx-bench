import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/rules/rule_set.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack_readiness.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/espresso_advisor.dart';
import 'package:kaffee_begleiter/features/brews/domain/recommendation.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';
import 'package:kaffee_begleiter/features/equipment/domain/grinder.dart';
import 'package:kaffee_begleiter/features/water/domain/water_checker.dart';
import 'package:kaffee_begleiter/features/water/domain/water_parameter.dart';
import 'package:kaffee_begleiter/features/water/domain/water_profile.dart';

import '../../../core/test_app_data.dart';

final _t = DateTime.utc(2026, 11, 16);

Grinder _grinder({
  FinerDirection dir = FinerDirection.down,
  double min = 1,
  double max = 30,
}) => Grinder(
  id: 'g',
  createdAt: _t,
  updatedAt: _t,
  name: 'G',
  scaleMin: min,
  scaleMax: max,
  scaleStep: 0.5,
  finerDirection: dir,
  deadSpaceG: 0,
);

Brew _brew(double setting, {int? time, Taste? taste}) => Brew(
  id: 'b',
  createdAt: _t,
  updatedAt: _t,
  method: BrewMethod.espresso,
  machineId: 'm',
  grinderId: 'g',
  packId: 'p',
  grindSetting: setting,
  doseG: 18,
  shotTimeS: time,
  taste: taste,
  startedAt: _t,
);

WaterProfile _water({double hardness = 80}) => WaterProfile(
  id: 'w',
  createdAt: _t,
  updatedAt: _t,
  name: 'W',
  hardnessPpm: hardness,
);

PackReadiness _ready(ReadinessStatus s, {int days = 0}) =>
    PackReadiness(status: s, readyDate: _t, staleDate: _t, daysLeft: days);

void main() {
  late EspressoAdvisor advisor;
  late WaterChecker checker;

  setUp(() async {
    advisor = EspressoAdvisor(loadTestRules('assets/brew_rules.json'));
    checker = await loadTestChecker();
  });

  Recommendation advise(
    Brew brew, {
    Grinder? grinder,
    WaterProfile? water,
    PackReadiness? readiness,
    bool useWater = true,
  }) {
    final w = useWater ? (water ?? _water()) : null;
    return advisor.advise(
      brew: brew,
      grinder: grinder ?? _grinder(),
      water: w,
      assessment: w == null ? null : checker.assess(w),
      readiness: readiness ?? _ready(ReadinessStatus.ready),
    );
  }

  group('R9 examples (finer = down)', () {
    void expectGrind(Brew b, double next, GrindDirection d, int steps) {
      final r = advise(b);
      expect(r.variable, RecommendationVariable.grind);
      expect(r.newSetting, next);
      expect(r.currentSetting, b.grindSetting);
      expect(r.direction, d);
      expect(r.steps, steps);
    }

    test('sour 27 s -> 11.5', () {
      expectGrind(
        _brew(12, time: 27, taste: Taste.sour),
        11.5,
        GrindDirection.finer,
        1,
      );
      expect(
        advise(_brew(12, time: 27, taste: Taste.sour)).reason,
        ReasonCode.tasteSour,
      );
    });

    test('bitter 17 s -> 11.0 (time wins, 2 steps)', () {
      expectGrind(
        _brew(12, time: 17, taste: Taste.bitter),
        11,
        GrindDirection.finer,
        2,
      );
    });

    test('weak 40 s -> 13.0', () {
      final b = _brew(12, time: 40, taste: Taste.weak);
      expectGrind(b, 13, GrindDirection.coarser, 2);
      expect(advise(b).reason, ReasonCode.timeTooLong);
    });

    test('sour 38 s -> 13.0', () {
      expectGrind(
        _brew(12, time: 38, taste: Taste.sour),
        13,
        GrindDirection.coarser,
        2,
      );
    });

    test('balanced 22 s -> 11.5', () {
      final b = _brew(12, time: 22, taste: Taste.balanced);
      expectGrind(b, 11.5, GrindDirection.finer, 1);
      expect(advise(b).reason, ReasonCode.timeTooShort);
    });

    test('balanced 27 s -> no change', () {
      final r = advise(_brew(12, time: 27, taste: Taste.balanced));
      expect(r.variable, RecommendationVariable.none);
      expect(r.reason, ReasonCode.balancedInWindow);
    });

    test('bitter and weak in window', () {
      expect(advise(_brew(12, time: 28, taste: Taste.bitter)).newSetting, 12.5);
      expect(advise(_brew(12, time: 28, taste: Taste.weak)).newSetting, 11.5);
    });

    test('window edges 25 and 30 count as in window', () {
      expect(
        advise(_brew(12, time: 25, taste: Taste.balanced)).reason,
        ReasonCode.balancedInWindow,
      );
      expect(
        advise(_brew(12, time: 30, taste: Taste.balanced)).reason,
        ReasonCode.balancedInWindow,
      );
      expect(advise(_brew(12, time: 20, taste: Taste.balanced)).steps, 1);
      expect(advise(_brew(12, time: 35, taste: Taste.balanced)).steps, 1);
      expect(advise(_brew(12, time: 36, taste: Taste.balanced)).steps, 2);
      expect(advise(_brew(12, time: 19, taste: Taste.balanced)).steps, 2);
    });

    test('scale end keeps setting', () {
      final r = advise(_brew(1, time: 27, taste: Taste.sour));
      expect(r.reason, ReasonCode.scaleEnd);
      expect(r.variable, RecommendationVariable.grind);
      expect(r.newSetting, 1);
      final top = advise(_brew(30, time: 40));
      expect(top.reason, ReasonCode.scaleEnd);
      expect(top.newSetting, 30);
    });

    test('clamps partially at the scale end', () {
      final r = advise(_brew(1.5, time: 10));
      expect(r.newSetting, 1);
      expect(r.reason, ReasonCode.timeTooShort);
      expect(r.steps, 1);
    });
  });

  group('finer = up (mirrored)', () {
    final g = _grinder(dir: FinerDirection.up);

    test('sour 27 s -> 12.5', () {
      expect(
        advise(_brew(12, time: 27, taste: Taste.sour), grinder: g).newSetting,
        12.5,
      );
    });

    test('bitter 17 s -> 13.0, weak 40 s -> 11.0', () {
      expect(
        advise(_brew(12, time: 17, taste: Taste.bitter), grinder: g).newSetting,
        13,
      );
      expect(
        advise(_brew(12, time: 40, taste: Taste.weak), grinder: g).newSetting,
        11,
      );
    });

    test('scale end at the max', () {
      final r = advise(_brew(30, time: 27, taste: Taste.sour), grinder: g);
      expect(r.reason, ReasonCode.scaleEnd);
      expect(r.newSetting, 30);
    });
  });

  group('check order', () {
    final sourFast = _brew(12, time: 17, taste: Taste.sour);

    test('no water comes first', () {
      final r = advise(
        sourFast,
        useWater: false,
        readiness: _ready(ReadinessStatus.resting, days: 3),
      );
      expect(r.variable, RecommendationVariable.water);
      expect(r.reason, ReasonCode.noWater);
    });

    test('water outside beats resting and grind', () {
      final r = advise(
        sourFast,
        water: _water(hardness: 500),
        readiness: _ready(ReadinessStatus.resting, days: 3),
      );
      expect(r.reason, ReasonCode.waterOutside);
      expect(r.waterParameter, WaterParameter.hardness);
      expect(r.waterValue, 500);
    });

    test('resting beats grind', () {
      final r = advise(
        sourFast,
        readiness: _ready(ReadinessStatus.resting, days: 3),
      );
      expect(r.variable, RecommendationVariable.rest);
      expect(r.reason, ReasonCode.packResting);
      expect(r.restDaysLeft, 3);
    });

    test('tooOld does not block', () {
      final r = advise(sourFast, readiness: _ready(ReadinessStatus.tooOld));
      expect(r.variable, RecommendationVariable.grind);
    });
  });

  group('sources and defaults', () {
    test('sources come from the deciding rule, never null', () {
      expect(advise(_brew(12, time: 20)).source, contains('coffeestudies'));
      expect(advise(_brew(12, time: 40)).source, contains('coffeestudies'));
      expect(
        advise(_brew(12, time: 27, taste: Taste.sour)).source,
        contains('clivecoffee'),
      );
      expect(advise(_brew(12), useWater: false).source, 'none');
    });

    test('empty rules fall back to defaults', () {
      final a = EspressoAdvisor(RuleSet(const []));
      final r = a.advise(
        brew: _brew(12, time: 17),
        grinder: _grinder(),
        water: _water(),
        assessment: null,
        readiness: _ready(ReadinessStatus.ready),
      );
      expect(r.newSetting, 11);
      expect(r.source, 'none');
    });
  });

  test('1000 advise calls stay far below 50 ms each', () {
    final b = _brew(12, time: 27, taste: Taste.sour);
    final sw = Stopwatch()..start();
    for (var i = 0; i < 1000; i++) {
      advise(b);
    }
    sw.stop();
    expect(sw.elapsedMicroseconds / 1000, lessThan(50 * 1000));
  });
}
