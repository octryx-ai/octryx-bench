import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/theme/app_colors.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const minimum = 4.5;
  final sets = {'light': AppColors.light, 'dark': AppColors.dark};

  for (final entry in sets.entries) {
    final c = entry.value;
    final backgrounds = {
      'surface': c.surface,
      'surfaceVariant': c.surfaceVariant,
    };
    final foregrounds = {
      'onSurface': c.onSurface,
      'success': c.success,
      'warning': c.warning,
      'error': c.error,
      'accent': c.accent,
    };
    for (final bg in backgrounds.entries) {
      for (final fg in foregrounds.entries) {
        test('${entry.key}: ${fg.key} on ${bg.key} >= 4.5:1', () {
          expect(_contrast(fg.value, bg.value), greaterThanOrEqualTo(minimum));
        });
      }
    }
  }

  test('spec luminance limits for light success and warning', () {
    expect(
      AppColors.light.success.computeLuminance(),
      lessThanOrEqualTo(0.139),
    );
    expect(
      AppColors.light.warning.computeLuminance(),
      lessThanOrEqualTo(0.167),
    );
  });

  test('white text on primary meets 4.5:1', () {
    const white = Color(0xFFFFFFFF);
    expect(
      _contrast(white, const Color(0xFF8A4B2A)),
      greaterThanOrEqualTo(minimum),
    );
    expect(
      _contrast(white, const Color(0xFF743F23)),
      greaterThanOrEqualTo(minimum),
    );
  });
}
