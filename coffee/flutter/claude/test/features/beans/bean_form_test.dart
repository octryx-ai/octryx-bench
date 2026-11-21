import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';

import '../../form_helpers.dart';
import '../../helpers.dart';
import 'bean_test_helpers.dart';

void main() {
  late AppData data;
  setUp(() async => data = await beanTestData());

  Future<void> openForm(WidgetTester tester, {Locale? locale}) async {
    await pumpApp(
      tester,
      data: data,
      height: tallViewport,
      locale: locale ?? const Locale('en'),
    );
    await goTo(tester, '/beans/new');
  }

  testWidgets('AC1 bean medium roasted 12 days ago shows Ready', (
    tester,
  ) async {
    await openForm(tester);
    await fillBeanForm(
      tester,
      name: 'Bohne 1',
      weight: '250',
      roastDate: '2026-11-04',
    );
    await tapKey(tester, 'form-save');
    expect(data.beans, hasLength(1));
    expect(data.packs, hasLength(1));
    expect(data.packs.single.sizeG, 250);
    expect(data.beans.single.leadTimeDays, 3);
    expect(data.beans.single.roastLevel, RoastLevel.medium);
    await goTo(tester, '/beans');
    expect(find.text('Bohne 1'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('250 g'), findsOneWidget);
  });

  testWidgets('saving pops back to the list', (tester) async {
    await pumpApp(tester, data: data, height: tallViewport);
    await tester.tap(find.byKey(const Key('nav-beans')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('action-add')));
    await tester.pumpAndSettle();
    await fillBeanForm(tester, name: 'Back', weight: '500');
    await tapKey(tester, 'kind-filter');
    await tapKey(tester, 'roast-dark');
    await enterField(tester, 'leadTime', '5');
    await enterField(tester, 'minStock', '120');
    await tapKey(tester, 'form-save');
    expect(find.byKey(const Key('field-name')), findsNothing);
    expect(find.text('Back'), findsOneWidget);
    final bean = data.beans.single;
    expect(bean.kind, BeanKind.filter);
    expect(bean.roastLevel, RoastLevel.dark);
    expect(bean.leadTimeDays, 5);
    expect(bean.minStockG, 120);
  });

  testWidgets('AC6 empty form shows name and size errors', (tester) async {
    await openForm(tester);
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Enter a value between 50 and 5000'), findsOneWidget);
    expect(data.beans, isEmpty);
  });

  testWidgets('AC6 errors in German', (tester) async {
    await openForm(tester, locale: const Locale('de'));
    await tapKey(tester, 'form-save');
    expect(find.text('Name eingeben'), findsOneWidget);
    expect(find.text('Wert zwischen 50 und 5000 eingeben'), findsOneWidget);
    expect(find.text('16.11.2026'), findsOneWidget);
  });

  testWidgets('AC6 long name and weight bounds', (tester) async {
    await openForm(tester);
    await fillBeanForm(tester, name: 'x' * 61, weight: '49');
    await tapKey(tester, 'form-save');
    expect(find.text('Use at most 60 characters'), findsOneWidget);
    expect(find.text('Enter a value between 50 and 5000'), findsOneWidget);
    await enterField(tester, 'weight', '5001');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a value between 50 and 5000'), findsOneWidget);
    await fillBeanForm(tester, name: 'y' * 60, weight: '50');
    await tapKey(tester, 'form-save');
    expect(data.beans.single.name, 'y' * 60);
  });

  testWidgets('lead time and minimum stock are validated', (tester) async {
    await openForm(tester);
    await fillBeanForm(tester, name: 'A', weight: '250');
    await enterField(tester, 'leadTime', '61');
    await enterField(tester, 'minStock', '5001');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a value between 0 and 60'), findsOneWidget);
    expect(find.text('Enter a value between 0 and 5000'), findsOneWidget);
    expect(data.beans, isEmpty);
  });

  testWidgets('roast date accepts shown format, German format and ISO', (
    tester,
  ) async {
    await openForm(tester);
    expect(find.text('16 Nov 2026'), findsOneWidget);
    await fillBeanForm(
      tester,
      name: 'A',
      weight: '250',
      roastDate: '9 Nov 2026',
    );
    await tapKey(tester, 'form-save');
    await openForm(tester);
    await fillBeanForm(
      tester,
      name: 'B',
      weight: '250',
      roastDate: '08.11.2026',
    );
    await tapKey(tester, 'form-save');
    await openForm(tester);
    await fillBeanForm(
      tester,
      name: 'C',
      weight: '250',
      roastDate: '2026-11-07',
    );
    await tapKey(tester, 'form-save');
    final days = [for (final p in data.packs) p.roastDate.day];
    expect(days, [9, 8, 7]);
  });

  testWidgets('roast date errors: missing, unreadable, future', (tester) async {
    await openForm(tester);
    await fillBeanForm(tester, name: 'A', weight: '250', roastDate: '');
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a date'), findsOneWidget);
    await enterField(tester, 'roastDate', 'yesterday');
    await tapKey(tester, 'form-save');
    expect(find.text('Use a date like 16 Nov 2026'), findsOneWidget);
    await enterField(tester, 'roastDate', '2026-11-17');
    await tapKey(tester, 'form-save');
    expect(find.text('The date must not be in the future'), findsOneWidget);
    expect(data.beans, isEmpty);
  });

  testWidgets('calendar button has a label and opens the date picker', (
    tester,
  ) async {
    await openForm(tester);
    expect(find.byTooltip('Pick a date'), findsOneWidget);
    await tapKey(tester, 'roast-date-picker');
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('10'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('10 Nov 2026'), findsOneWidget);
  });

  testWidgets('pack form adds a pack to the bean', (tester) async {
    final bean = await seedBean(data, 'Packs', roasts: []);
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/beans');
    await tapKey(tester, 'bean-${bean.id}');
    await tapKey(tester, 'pack-add');
    expect(find.text('Add pack'), findsWidgets);
    await tapKey(tester, 'form-save');
    expect(find.text('Enter a value between 50 and 5000'), findsOneWidget);
    await enterField(tester, 'weight', '1000');
    await enterField(tester, 'roastDate', '2026-11-09');
    await tapKey(tester, 'form-save');
    expect(data.packsOf(bean.id).single.sizeG, 1000);
    expect(find.text('Roasted 9 Nov 2026'), findsOneWidget);
  });

  testWidgets('editing a bean keeps its packs and changes the fields', (
    tester,
  ) async {
    final bean = await seedBean(data, 'Old name');
    await pumpApp(tester, data: data, height: tallViewport);
    await goTo(tester, '/beans');
    await tapKey(tester, 'bean-${bean.id}');
    await tapKey(tester, 'action-edit');
    expect(find.byKey(const Key('field-weight')), findsNothing);
    await enterField(tester, 'name', 'New name');
    await tapKey(tester, 'form-save');
    expect(data.beanById(bean.id)!.name, 'New name');
    expect(data.packsOf(bean.id), hasLength(1));
    expect(find.text('New name'), findsWidgets);
  });
}
