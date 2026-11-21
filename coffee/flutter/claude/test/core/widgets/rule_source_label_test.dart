import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/rules/rule_entry.dart';
import 'package:kaffee_begleiter/core/theme/app_theme.dart';
import 'package:kaffee_begleiter/core/widgets/rule_source_label.dart';
import 'package:kaffee_begleiter/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, RuleEntry entry, Locale locale) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: RuleSourceLabel(entry: entry)),
    ),
  );
}

void main() {
  const none = RuleEntry(
    key: 'a',
    value: 1,
    source: 'none',
    retrieved: '2026-11-16',
  );
  const sourced = RuleEntry(
    key: 'b',
    value: 1,
    source: 'https://example.org',
    retrieved: '2026-11-16',
  );

  testWidgets('source none shows default without source (DE)', (tester) async {
    await _pump(tester, none, const Locale('de'));
    expect(find.text('Standardwert ohne Quelle'), findsOneWidget);
  });

  testWidgets('source none shows default without source (EN)', (tester) async {
    await _pump(tester, none, const Locale('en'));
    expect(find.text('Default without source'), findsOneWidget);
  });

  testWidgets('real source shows URL and localized date', (tester) async {
    await _pump(tester, sourced, const Locale('de'));
    expect(find.textContaining('https://example.org'), findsOneWidget);
    expect(find.textContaining('16.11.2026'), findsOneWidget);
    await _pump(tester, sourced, const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.textContaining('16 Nov 2026'), findsOneWidget);
  });
}
