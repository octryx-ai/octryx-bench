import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/inventory/presentation/stock_bar.dart';
import 'package:kaffee_begleiter/core/theme/app_colors.dart';
import 'package:kaffee_begleiter/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

import '../../form_helpers.dart';
import '../../helpers.dart';
import '../brews/brew_test_helpers.dart';

/// 28 espresso brews of 18 g in the last 28 days (18 g/day) and a pack with
/// [left] grams remaining.
Future<BrewSeed> consumingSeed(double left) async {
  final s = await seedBrewData();
  await s.data.updatePack(s.pack.copyWith(sizeG: 5000, remainingG: 5000));
  for (var i = 0; i < 28; i++) {
    await s.brew(at: DateTime.utc(2026, 11, 16 - i, 8));
  }
  await s.data.updatePack(
    s.data.packById(s.pack.id)!.copyWith(remainingG: left),
  );
  return s;
}

Future<void> openDetail(
  WidgetTester tester,
  BrewSeed s, {
  Locale? locale,
}) async {
  await pumpApp(
    tester,
    data: s.data,
    height: tallViewport,
    locale: locale ?? const Locale('en'),
  );
  await goTo(tester, '/beans');
  await tapKey(tester, 'bean-${s.bean.id}');
}

void main() {
  test('stock bar fill fraction and colour rules', () {
    expect(StockBar.fractionFor(250, 270), closeTo(250 / 540, 1e-9));
    expect(StockBar.fractionFor(1000, 270), 1);
    expect(StockBar.fractionFor(0, 270), 0);
    expect(StockBar.fractionFor(50, 0), 1);
    const c = AppColors.light;
    expect(StockBar.colorFor(c, 300, 270), c.success);
    expect(StockBar.colorFor(c, 250, 270), c.warning);
    expect(StockBar.colorFor(c, 270, 270), c.warning);
    expect(StockBar.colorFor(c, 0, 270), isNull);
  });

  testWidgets('stock bar shows marker and fill, empty one an error border', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Column(
            children: const [
              StockBar(stockG: 250, orderPoint: 270),
              StockBar(stockG: 0, orderPoint: 270),
            ],
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('stock-bar-marker')), findsNWidgets(2));
    expect(find.byKey(const Key('stock-bar-fill')), findsOneWidget);
  });

  testWidgets('250 g with 18 g/day shows the order banner', (tester) async {
    final s = await consumingSeed(250);
    await openDetail(tester, s);
    expect(find.byKey(const Key('order-banner')), findsOneWidget);
    expect(find.text('Order now'), findsWidgets);
  });

  testWidgets('300 g with 18 g/day shows no order banner', (tester) async {
    final s = await consumingSeed(300);
    await openDetail(tester, s);
    expect(find.byKey(const Key('order-banner')), findsNothing);
  });

  testWidgets('gap banner names the dates and opens the pack', (tester) async {
    final s = await consumingSeed(90);
    await s.data.addPack(
      beanId: s.bean.id,
      roastDate: Pack.parseDate('2026-11-15'),
      sizeG: 250,
    );
    await openDetail(tester, s);
    expect(
      find.text('No ready coffee from 21 Nov 2026 to 24 Nov 2026'),
      findsOneWidget,
    );
    final open = find.textContaining('Open pack');
    expect(open, findsOneWidget);
    expect(s.data.packById(s.pack.id)!.openedAt, isNull);
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(s.data.packById(s.pack.id)!.openedAt, isNotNull);
  });

  testWidgets('without consumption there is no gap banner', (tester) async {
    final s = await seedBrewData();
    await openDetail(tester, s);
    expect(find.byKey(const Key('gap-banner')), findsNothing);
    expect(find.byKey(const Key('order-banner')), findsNothing);
  });

  testWidgets('gap with an opened pack only: banner says Order now', (
    tester,
  ) async {
    final s = await consumingSeed(90);
    await s.data.openPack(s.pack.id);
    await openDetail(tester, s);
    final banner = find.byKey(const Key('gap-banner'));
    expect(banner, findsOneWidget);
    expect(
      find.descendant(of: banner, matching: find.text('Order now')),
      findsOneWidget,
    );
    expect(find.textContaining('Open pack'), findsNothing);
  });

  testWidgets('the gap banner says Jetzt bestellen in German', (tester) async {
    final s = await consumingSeed(90);
    await s.data.openPack(s.pack.id);
    await openDetail(tester, s, locale: const Locale('de'));
    expect(
      find.descendant(
        of: find.byKey(const Key('gap-banner')),
        matching: find.text('Jetzt bestellen'),
      ),
      findsOneWidget,
    );
  });
}
