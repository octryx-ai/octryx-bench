import 'brew_field_error.dart';

/// Validation of brew form values (SPEC section 5 limits).
class BrewValidation {
  const BrewValidation._();

  /// Dose must be 5 to 40 g.
  static BrewFieldError? validateDose(double? dose) {
    if (dose == null) return BrewFieldError.doseRequired;
    return dose < 5 || dose > 40 ? BrewFieldError.doseOutOfRange : null;
  }

  /// Yield must be 1 to 4 times [dose]; skips the range check if [dose] is
  /// unknown.
  static BrewFieldError? validateYield(double? yield, double? dose) {
    if (yield == null) return BrewFieldError.yieldRequired;
    if (dose == null) return yield <= 0 ? BrewFieldError.yieldOutOfRange : null;
    return yield < dose || yield > 4 * dose
        ? BrewFieldError.yieldOutOfRange
        : null;
  }

  /// Shot time must be 1 to 120 s; null is an error only if [required].
  static BrewFieldError? validateShotTime(
    int? seconds, {
    required bool required,
  }) {
    if (seconds == null) {
      return required ? BrewFieldError.shotTimeRequired : null;
    }
    return seconds < 1 || seconds > 120
        ? BrewFieldError.shotTimeOutOfRange
        : null;
  }

  /// Rating must be 1 to 5; null is fine.
  static BrewFieldError? validateRating(int? rating) {
    if (rating == null) return null;
    return rating < 1 || rating > 5 ? BrewFieldError.ratingOutOfRange : null;
  }

  /// Purge must be 0 to 50 g; null is fine.
  static BrewFieldError? validatePurge(double? purge) {
    if (purge == null) return null;
    return purge < 0 || purge > 50 ? BrewFieldError.purgeOutOfRange : null;
  }
}
