import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/format/app_format.dart';

void main() {
  final day = DateTime(2026, 11, 16);

  test('every German locale formats dd.MM.yyyy', () {
    for (final locale in const [
      Locale('de'),
      Locale('de', 'CH'),
      Locale('de', 'DE'),
      Locale('de', 'AT'),
    ]) {
      expect(AppFormat(locale).date(day), '16.11.2026', reason: '$locale');
    }
  });

  test('English formats d MMM yyyy', () {
    expect(const AppFormat(Locale('en')).date(day), '16 Nov 2026');
    expect(const AppFormat(Locale('en', 'GB')).date(day), '16 Nov 2026');
    expect(
      const AppFormat(Locale('en')).date(DateTime(2026, 3, 5)),
      '5 Mar 2026',
    );
  });

  test('decimal point in both languages', () {
    expect(const AppFormat(Locale('de', 'CH')).decimal(15.5), '15.5');
    expect(const AppFormat(Locale('en')).decimal(15.5), '15.5');
    expect(const AppFormat(Locale('de')).decimal(2.5, digits: 2), '2.50');
  });

  test('plain drops trailing zeros and keeps the decimal point', () {
    expect(AppFormat.plain(30), '30');
    expect(AppFormat.plain(0.5), '0.5');
    expect(AppFormat.plain(2.5), '2.5');
    expect(const AppFormat(Locale('de')).number(12.3), '12.3');
  });

  test('parse accepts point and comma and rejects garbage', () {
    expect(AppFormat.parse('2.5'), 2.5);
    expect(AppFormat.parse(' 2,5 '), 2.5);
    expect(AppFormat.parse(''), isNull);
    expect(AppFormat.parse('abc'), isNull);
    expect(AppFormat.parse('NaN'), isNull);
    expect(AppFormat.parse('Infinity'), isNull);
  });
}
