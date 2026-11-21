import 'package:flutter/widgets.dart';

/// Locale-aware formatting: every German locale uses `dd.MM.yyyy`, English
/// `d MMM yyyy`; the decimal separator is always a point.
class AppFormat {
  /// Creates a formatter for [locale].
  const AppFormat(this.locale);

  /// Formatter for the locale of [context].
  factory AppFormat.of(BuildContext context) =>
      AppFormat(Localizations.localeOf(context));

  static const _englishMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Locale this formatter follows.
  final Locale locale;

  /// Whether the locale is any German variant.
  bool get isGerman => locale.languageCode == 'de';

  /// Formats a calendar date, e.g. `16.11.2026` or `16 Nov 2026`.
  String date(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    if (isGerman) {
      final day = value.day.toString().padLeft(2, '0');
      final month = value.month.toString().padLeft(2, '0');
      return '$day.$month.$year';
    }
    return '${value.day} ${_englishMonths[value.month - 1]} $year';
  }

  /// Formats [value] with [digits] decimals and a decimal point.
  String decimal(num value, {int digits = 1}) => value.toStringAsFixed(digits);
}
