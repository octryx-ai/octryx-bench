import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack_readiness.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/filter_advisor.dart';
import 'package:kaffee_begleiter/features/brews/domain/recommendation.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';
import 'package:kaffee_begleiter/features/equipment/domain/grinder.dart';
import 'package:kaffee_begleiter/features/water/domain/water_checker.dart';
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

Brew _brew(double setting, {int? drawdown, Taste? taste}) => Brew(
  id: 'b',
  createdAt: _t,
  updatedAt: _t,
  method: BrewMethod.v60,
  grinderId: 'g',
  packId: 'p',
  grindSetting: setting,
  doseG: 20,
  drawdownS: drawdown,
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
  late FilterAdvisor advisor;
  late WaterChecker checker;

  setUp(() async {
    advisor = FilterAdvisor(loadTestRules('assets/brew_rules.json'));
    checker = await loadTestChecker();
  });

  Recommendation advise(
    Brew brew, {
    Grinder? grinder,
    double hardness = 80,
    bool useWater = true,
    PackReadiness? readiness,
  }) {
    final w = useWater ? _water(hardness: hardness) : null;
    return advisor.advise(
      brew: brew,
      grinder: grinder ?? _grinder(),
      water: w,
      assessment: w == null ? null : checker.assess(w),
      readiness: readiness ?? _ready(ReadinessStatus.ready),
    );
  }

  void expectGrind(Recommendation r, double next, GrindDirection d, int n) {
    expect(r.variable, RecommendationVariable.grind);
    expect(r.newSetting, next);
    expect(r.direction, d);
    expect(r.steps, n);
  }

  group('R11 examples (finer = down, setting 20)', () {
    test('255 s bitter -> 20.5 coarser 1', () {
      final r = advise(_brew(20, drawdown: 255, taste: Taste.bitter));
      expectGrind(r, 20.5, GrindDirection.coarser, 1);
      expect(r.reason, ReasonCode.timeTooLong);
      expect(r.source, contains('coffeehero'));
    });

    test('150 s -> 19.5 (not below 150)', () {
      expectGrind(
        advise(_brew(20, drawdown: 150)),
        19.5,
        GrindDirection.finer,
        1,
      );
    });

    test('140 s -> 19.0 two steps', () {
      final r = advise(_brew(20, drawdown: 140));
      expectGrind(r, 19, GrindDirection.finer, 2);
      expect(r.reason, ReasonCode.timeTooShort);
    });

    test('200 s sour -> 19.5', () {
      final r = advise(_brew(20, drawdown: 200, taste: Taste.sour));
      expectGrind(r, 19.5, GrindDirection.finer, 1);
      expect(r.reason, ReasonCode.tasteSour);
    });
  });

  group('boundaries', () {
    test('270 is one step, 271 two', () {
      expectGrind(
        advise(_brew(20, drawdown: 270)),
        20.5,
        GrindDirection.coarser,
        1,
      );
      expectGrind(
        advise(_brew(20, drawdown: 271)),
        21,
        GrindDirection.coarser,
        2,
      );
    });

    test('240 and 165 are inside the window', () {
      expect(
        advise(_brew(20, drawdown: 240)).variable,
        RecommendationVariable.none,
      );
      expect(
        advise(_brew(20, drawdown: 165)).variable,
        RecommendationVariable.none,
      );
      expectGrind(
        advise(_brew(20, drawdown: 241)),
        20.5,
        GrindDirection.coarser,
        1,
      );
      expectGrind(
        advise(_brew(20, drawdown: 164)),
        19.5,
        GrindDirection.finer,
        1,
      );
    });

    test('taste in window: weak finer, bitter coarser, balanced none', () {
      expectGrind(
        advise(_brew(20, drawdown: 200, taste: Taste.weak)),
        19.5,
        GrindDirection.finer,
        1,
      );
      expectGrind(
        advise(_brew(20, drawdown: 200, taste: Taste.bitter)),
        20.5,
        GrindDirection.coarser,
        1,
      );
      final r = advise(_brew(20, drawdown: 200, taste: Taste.balanced));
      expect(r.variable, RecommendationVariable.none);
      expect(r.reason, ReasonCode.balancedInWindow);
      expect(advise(_brew(20)).reason, ReasonCode.balancedInWindow);
    });
  });

  test('mirrored grinder: finer goes up', () {
    final g = _grinder(dir: FinerDirection.up);
    expectGrind(
      advise(_brew(20, drawdown: 140), grinder: g),
      21,
      GrindDirection.finer,
      2,
    );
    expectGrind(
      advise(_brew(20, drawdown: 255), grinder: g),
      19.5,
      GrindDirection.coarser,
      1,
    );
  });

  test('scale end', () {
    final g = _grinder(min: 20, max: 30);
    final r = advise(_brew(20, drawdown: 140), grinder: g);
    expect(r.reason, ReasonCode.scaleEnd);
    expect(r.newSetting, 20);
    final partial = advise(_brew(20.5, drawdown: 140), grinder: g);
    expect(partial.newSetting, 20);
    expect(partial.steps, 1);
  });

  group('order', () {
    test('no water first', () {
      final r = advise(
        _brew(20, drawdown: 140),
        useWater: false,
        readiness: _ready(ReadinessStatus.resting, days: 2),
      );
      expect(r.reason, ReasonCode.noWater);
    });

    test('water outside beats resting and grind', () {
      final r = advise(
        _brew(20, drawdown: 140),
        hardness: 400,
        readiness: _ready(ReadinessStatus.resting, days: 2),
      );
      expect(r.variable, RecommendationVariable.water);
      expect(r.reason, ReasonCode.waterOutside);
    });

    test('resting beats grind', () {
      final r = advise(
        _brew(20, drawdown: 140),
        readiness: _ready(ReadinessStatus.resting, days: 2),
      );
      expect(r.variable, RecommendationVariable.rest);
      expect(r.restDaysLeft, 2);
    });
  });
}
