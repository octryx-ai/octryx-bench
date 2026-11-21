import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  const keys = [
    'button-default',
    'button-hover',
    'button-pressed',
    'button-focus',
    'button-disabled',
    'button-loading',
    'card-default',
    'card-hover',
    'card-selected',
    'card-disabled',
    'card-empty',
    'card-loading',
    'card-error',
    'field-default',
    'field-focus',
    'field-error',
    'field-disabled',
    'chip-ready',
    'chip-resting',
    'chip-tooold',
    'banner-info',
    'banner-warning',
    'banner-error',
    'empty-state',
    'coming-soon',
    'rule-none',
    'rule-source',
    'color-primary',
    'color-success',
    'color-warning',
    'color-error',
  ];

  for (final dark in [false, true]) {
    testWidgets('style guide shows all states (dark: $dark)', (tester) async {
      await pumpApp(
        tester,
        height: 12000,
        brightness: dark ? Brightness.dark : Brightness.light,
      );
      await goTo(tester, '/styleguide');
      for (final k in keys) {
        final finder = find.byKey(Key('sg-$k'));
        expect(finder, findsOneWidget, reason: k);
      }
      expect(find.text('Try again'), findsWidgets);
      expect(find.text('Default without source'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
