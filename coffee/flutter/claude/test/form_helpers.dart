import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Viewport height that keeps every form field built.
const double tallViewport = 1800;

/// Types [text] into the AppField with key `field-[name]`.
Future<void> enterField(WidgetTester tester, String name, String text) async {
  final field = find.descendant(
    of: find.byKey(Key('field-$name')),
    matching: find.byType(TextField),
  );
  await tester.enterText(field, text);
  await tester.pump();
}

/// Taps the widget with [key] and settles.
Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
