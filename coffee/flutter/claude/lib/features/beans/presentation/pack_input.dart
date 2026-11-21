import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/bean_validation.dart';
import 'bean_format.dart';

/// Text controllers of the pack fields (roast date and weight) shared by the
/// bean form and the pack form, with their validation.
class PackInput {
  /// Controller of the roast date text.
  final TextEditingController roastDate = TextEditingController();

  /// Controller of the weight text.
  final TextEditingController weight = TextEditingController();

  /// Releases both controllers.
  void dispose() {
    roastDate.dispose();
    weight.dispose();
  }

  /// Checks both fields on [today]; errors are localized.
  PackInputResult check(AppLocalizations l, AppFormat format, DateTime today) {
    final text = roastDate.text.trim();
    final date = AppFormat.parseDate(text);
    final unreadable = text.isNotEmpty && date == null;
    final dateError = BeanValidation.validateRoastDate(date, today);
    final size = AppFormat.parse(weight.text);
    final sizeError = BeanValidation.validateSizeG(size);
    return PackInputResult(
      roastDate: date,
      sizeG: size,
      dateError: unreadable
          ? l.dateInvalid(format.date(today))
          : dateError == null
          ? null
          : BeanFormat.error(l, dateError),
      sizeError: sizeError == null ? null : BeanFormat.error(l, sizeError),
    );
  }
}

/// Outcome of [PackInput.check].
class PackInputResult {
  /// Creates a result.
  const PackInputResult({
    this.roastDate,
    this.sizeG,
    this.dateError,
    this.sizeError,
  });

  /// Parsed roast date (UTC, date only), null if missing or invalid.
  final DateTime? roastDate;

  /// Parsed weight in grams, null if missing or invalid.
  final double? sizeG;

  /// Error line for the date field.
  final String? dateError;

  /// Error line for the weight field.
  final String? sizeError;

  /// Whether both fields are acceptable.
  bool get isValid => dateError == null && sizeError == null;
}
