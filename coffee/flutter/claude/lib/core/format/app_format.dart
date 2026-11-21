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

  /// Parses a typed calendar date: ISO `2026-11-16`, German `16.11.2026`
  /// or English `16 Nov 2026`. Returns a UTC date-only value, or null if the
  /// text is not a real date.
  static DateTime? parseDate(String input) {
    final text = input.trim();
    int? year, month, day;
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(text);
    final de = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(text);
    final en = RegExp(r'^(\d{1,2}) ([A-Za-z]{3}) (\d{4})$').firstMatch(text);
    if (iso != null) {
      year = int.parse(iso[1]!);
      month = int.parse(iso[2]!);
      day = int.parse(iso[3]!);
    } else if (de != null) {
      day = int.parse(de[1]!);
      month = int.parse(de[2]!);
      year = int.parse(de[3]!);
    } else if (en != null) {
      day = int.parse(en[1]!);
      month =
          _englishMonths.indexWhere(
            (m) => m.toLowerCase() == en[2]!.toLowerCase(),
          ) +
          1;
      year = int.parse(en[3]!);
    }
    if (year == null || month == null || day == null || month < 1) return null;
    final date = DateTime.utc(year, month, day);
    return date.year == year && date.month == month && date.day == day
        ? date
        : null;
  }

  /// Formats [value] with [digits] decimals and a decimal point.
  String decimal(num value, {int digits = 1}) => value.toStringAsFixed(digits);

  /// Formats [value] without trailing zeros: `30` for 30.0, `0.5` for 0.5.
  /// Always a decimal point, in every language.
  static String plain(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  /// Instance shortcut for [plain].
  String number(num value) => plain(value);

  /// Parses user input; both `.` and `,` are accepted as decimal separator.
  /// Returns null for empty or non-numeric text.
  static double? parse(String input) {
    final text = input.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return value;
  }
}
