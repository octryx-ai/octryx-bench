import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/kaffee_app.dart';

import '../helpers.dart';

void main() {
  testWidgets('German locale shows German texts', (tester) async {
    await pumpApp(tester, locale: const Locale('de', 'CH'));
    for (final t in ['Heute', 'Bohnen', 'Brühen', 'Ausrüstung', 'Mehr']) {
      expect(find.text(t), findsWidgets, reason: t);
    }
    expect(find.text('Kommt bald'), findsOneWidget);
  });

  testWidgets('English locale shows English texts', (tester) async {
    await pumpApp(tester);
    for (final t in ['Today', 'Beans', 'Brew', 'Equipment', 'More']) {
      expect(find.text(t), findsWidgets, reason: t);
    }
    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('unsupported locale falls back to English', (tester) async {
    await pumpApp(tester, locale: const Locale('fr', 'FR'));
    expect(find.text('Coming soon'), findsOneWidget);
  });

  test('locale resolution maps every German variant to de', () {
    const supported = [Locale('en'), Locale('de')];
    expect(
      KaffeeApp.resolveLocale(const Locale('de', 'AT'), supported),
      const Locale('de'),
    );
    expect(
      KaffeeApp.resolveLocale(const Locale('it'), supported),
      const Locale('en'),
    );
    expect(KaffeeApp.resolveLocale(null, supported), const Locale('en'));
  });
}
