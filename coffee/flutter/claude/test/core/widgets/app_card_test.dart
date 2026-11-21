import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/theme/app_theme.dart';
import 'package:kaffee_begleiter/core/widgets/app_card.dart';

BoxDecoration _decoration(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(AppCard),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return box.decoration as BoxDecoration;
}

Future<void> _pump(WidgetTester tester, ThemeData theme) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    home: const Scaffold(body: AppCard(child: Text('x'))),
  ),
);

void main() {
  testWidgets('dark card: 1 dp border, no shadow', (tester) async {
    await _pump(tester, AppTheme.dark());
    final d = _decoration(tester);
    expect(d.boxShadow, isNull);
    final border = d.border! as Border;
    expect(border.top.width, 1);
  });

  testWidgets('light card: border and soft shadow', (tester) async {
    await _pump(tester, AppTheme.light());
    final d = _decoration(tester);
    expect(d.boxShadow, hasLength(1));
    expect(d.boxShadow!.single.offset.dy, 2);
    expect(d.boxShadow!.single.blurRadius, 8);
    expect(d.border, isNotNull);
  });
}
