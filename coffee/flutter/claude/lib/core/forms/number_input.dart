import '../../l10n/app_localizations.dart';
import '../format/app_format.dart';

/// Result of checking one numeric text field.
class NumberInput {
  /// Creates a result.
  const NumberInput({this.value, this.error});

  /// Parsed value in the unit typed by the user; null if empty or invalid.
  final double? value;

  /// Localized error text, or null if the input is acceptable.
  final String? error;

  /// Whether the input is acceptable (possibly empty if optional).
  bool get isValid => error == null;

  /// Checks [text] against `min..max`.
  ///
  /// Empty text is an error unless [required] is false (then [value] stays
  /// null). [stored] converts the typed value to the unit the bounds are in
  /// (e.g. fH to ppm); [shownMin] and [shownMax] are the bounds printed in
  /// the error and default to [min] and [max].
  static NumberInput check(
    AppLocalizations l,
    String text, {
    required double min,
    required double max,
    bool required = true,
    double Function(double)? stored,
    double? shownMin,
    double? shownMax,
  }) {
    if (text.trim().isEmpty && !required) return const NumberInput();
    final value = AppFormat.parse(text);
    final converted = value == null ? null : (stored?.call(value) ?? value);
    if (converted == null || converted < min || converted > max) {
      return NumberInput(
        error: l.rangeError(
          AppFormat.plain(shownMin ?? min),
          AppFormat.plain(shownMax ?? max),
        ),
      );
    }
    return NumberInput(value: value);
  }
}
