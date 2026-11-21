import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_field_error.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_pour.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_validation.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';

void main() {
  test('dose 5..40', () {
    expect(BrewValidation.validateDose(null), BrewFieldError.doseRequired);
    expect(BrewValidation.validateDose(4.9), BrewFieldError.doseOutOfRange);
    expect(BrewValidation.validateDose(5), isNull);
    expect(BrewValidation.validateDose(40), isNull);
    expect(BrewValidation.validateDose(40.1), BrewFieldError.doseOutOfRange);
  });

  test('yield 1..4 x dose', () {
    expect(
      BrewValidation.validateYield(null, 18),
      BrewFieldError.yieldRequired,
    );
    expect(BrewValidation.validateYield(36, 18), isNull);
    expect(BrewValidation.validateYield(18, 18), isNull);
    expect(BrewValidation.validateYield(72, 18), isNull);
    expect(
      BrewValidation.validateYield(0.9 * 18, 18),
      BrewFieldError.yieldOutOfRange,
    );
    expect(
      BrewValidation.validateYield(4.1 * 18, 18),
      BrewFieldError.yieldOutOfRange,
    );
  });

  test('shot time 1..120', () {
    String? e(int? s, {bool r = true}) =>
        BrewValidation.validateShotTime(s, required: r)?.name;
    expect(e(0), 'shotTimeOutOfRange');
    expect(e(1), isNull);
    expect(e(120), isNull);
    expect(e(121), 'shotTimeOutOfRange');
    expect(e(null), 'shotTimeRequired');
    expect(e(null, r: false), isNull);
  });

  test('rating 1..5 and purge 0..50', () {
    expect(BrewValidation.validateRating(0), BrewFieldError.ratingOutOfRange);
    expect(BrewValidation.validateRating(1), isNull);
    expect(BrewValidation.validateRating(5), isNull);
    expect(BrewValidation.validateRating(6), BrewFieldError.ratingOutOfRange);
    expect(BrewValidation.validateRating(null), isNull);
    expect(BrewValidation.validatePurge(-1), BrewFieldError.purgeOutOfRange);
    expect(BrewValidation.validatePurge(0), isNull);
    expect(BrewValidation.validatePurge(50), isNull);
    expect(BrewValidation.validatePurge(50.1), BrewFieldError.purgeOutOfRange);
  });

  test('Brew JSON round trip and copyWith clearing', () {
    final t = DateTime.utc(2026, 11, 16, 8);
    final b = Brew(
      id: 'x',
      createdAt: t,
      updatedAt: t,
      method: BrewMethod.v60,
      grinderId: 'g',
      packId: 'p',
      grindSetting: 14.5,
      doseG: 15,
      taste: Taste.sour,
      rating: 4,
      startedAt: t,
      waterTotalG: 240,
      bloomG: 30,
      pours: const [BrewPour(atS: 45, cumulativeG: 90)],
      drawdownS: 170,
    );
    final back = Brew.fromJson(b.toJson());
    expect(back.toJson(), b.toJson());
    expect(back.pours.single, const BrewPour(atS: 45, cumulativeG: 90));
    final cleared = b.copyWith(taste: null, rating: null, doseG: 16);
    expect(cleared.taste, isNull);
    expect(cleared.rating, isNull);
    expect(cleared.doseG, 16);
    expect(cleared.drawdownS, 170);
    expect(b.copyWith().taste, Taste.sour);
    expect(BrewMethod.parse('chemex'), BrewMethod.chemex);
    expect(() => Taste.parse('x'), throwsFormatException);
  });
}
