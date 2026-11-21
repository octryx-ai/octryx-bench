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
}
