import 'bean_field_error.dart';
import 'rest_calculator.dart';

/// Field validators for bean and pack forms; null means valid.
class BeanValidation {
  const BeanValidation._();

  /// Name: 1 to 60 characters after trimming.
  static BeanFieldError? validateName(String name) {
    final n = name.trim().length;
    if (n == 0) return BeanFieldError.nameRequired;
    return n > 60 ? BeanFieldError.nameTooLong : null;
  }

  /// Pack size: required, 50 to 5000 g.
  static BeanFieldError? validateSizeG(double? g) {
    if (g == null) return BeanFieldError.sizeRequired;
    return g < 50 || g > 5000 ? BeanFieldError.sizeOutOfRange : null;
  }

  /// Lead time: required, 0 to 60 days.
  static BeanFieldError? validateLeadTime(int? days) {
    if (days == null) return BeanFieldError.leadTimeRequired;
    return days < 0 || days > 60 ? BeanFieldError.leadTimeOutOfRange : null;
  }

  /// Minimum stock: optional, 0 to 5000 g.
  static BeanFieldError? validateMinStock(double? g) {
    if (g == null) return null;
    return g < 0 || g > 5000 ? BeanFieldError.minStockOutOfRange : null;
  }

  /// Roast date: required and not after [today] (calendar days).
  static BeanFieldError? validateRoastDate(DateTime? d, DateTime today) {
    if (d == null) return BeanFieldError.roastDateRequired;
    return RestCalculator.dateOnly(d).isAfter(RestCalculator.dateOnly(today))
        ? BeanFieldError.roastDateInFuture
        : null;
  }
}
