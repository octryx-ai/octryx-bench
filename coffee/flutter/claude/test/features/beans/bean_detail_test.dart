import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/presentation/bean_image.dart';

import '../../form_helpers.dart';
import '../../helpers.dart';
import 'bean_test_helpers.dart';

void main() {
  late AppData data;
  late Bean bean;
  setUp(() async {
    data = await beanTestData();
    bean = await seedBean(
      data,
      'Detail bean',
      roaster: 'Rösterei Nord',
      roasts: ['2026-11-09', '2026-11-01'],
    );
  });

  Future<void> openDetail(WidgetTester tester, {Locale? locale}) async {
    await pumpApp(
      tester,
      data: data,
      height: tallViewport,
      locale: locale ?? const Locale('en'),
    );
    await goTo(tester, '/beans');
    await tapKey(tester, 'bean-${bean.id}');
  }

  testWidgets('AC7 detail shows header, tiles and the pack list (en)', (
    tester,
  ) async {
    await openDetail(tester);
    expect(find.text('Detail bean'), findsWidgets);
    expect(find.text('Rösterei Nord'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('tile-remaining')),
        matching: find.text('500 g'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('tile-ready')),
        matching: find.text('11 Nov 2026'),
      ),
      findsOneWidget,
    );
    expect(find.text('Roasted 9 Nov 2026'), findsOneWidget);
    expect(find.text('Roasted 1 Nov 2026'), findsOneWidget);
    expect(find.text('Resting, 3 days left'), findsOneWidget);
    expect(find.text('Ready'), findsNWidgets(2));
    expect(find.text('250 g of 250 g'), findsNWidgets(2));
    expect(find.text('Open'), findsNWidgets(2));
    final header = tester.getSize(find.byType(BeanImage));
    expect(header.height, 160);
  });

  testWidgets('detail in German uses localized dates and labels', (
    tester,
  ) async {
    await openDetail(tester, locale: const Locale('de'));
    expect(find.text('11.11.2026'), findsOneWidget);
    expect(find.text('Geröstet am 09.11.2026'), findsOneWidget);
    expect(find.text('Ruht noch 3 Tage'), findsOneWidget);
    expect(find.text('Öffnen'), findsNWidgets(2));
    expect(find.text('Packung hinzufügen'), findsOneWidget);
    expect(find.text('Restgramm'), findsOneWidget);
  });

  testWidgets('AC7 Open marks the pack as opened', (tester) async {
    await openDetail(tester);
    final pack = data.packsOf(bean.id).first;
    expect(pack.openedAt, isNull);
    await tapKey(tester, 'pack-open-${pack.id}');
    expect(data.packById(pack.id)!.openedAt, isNotNull);
    expect(find.text('Opened on 16 Nov 2026'), findsOneWidget);
    expect(find.byKey(Key('pack-open-${pack.id}')), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('icon buttons carry Semantics labels and 48 dp targets', (
    tester,
  ) async {
    await openDetail(tester);
    final pack = data.packsOf(bean.id).first;
    expect(find.byTooltip('Edit pack'), findsNWidgets(2));
    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.byTooltip('Delete Detail bean'), findsOneWidget);
    final edit = tester.getSize(find.byKey(Key('pack-edit-${pack.id}')));
    expect(edit.width, greaterThanOrEqualTo(48));
    expect(edit.height, greaterThanOrEqualTo(48));
    final open = tester.getSize(find.byKey(Key('pack-open-${pack.id}')));
    expect(open.height, greaterThanOrEqualTo(48));
  });

  testWidgets('deleting a pack removes it and updates the tiles', (
    tester,
  ) async {
    await openDetail(tester);
    final pack = data.packsOf(bean.id).first;
    await tapKey(tester, 'pack-delete-${pack.id}');
    expect(find.byKey(Key('pack-${pack.id}')), findsNothing);
    expect(data.packsOf(bean.id), hasLength(1));
    expect(find.text('250 g'), findsWidgets);
  });

  testWidgets('editing a pack changes its size and roast date', (tester) async {
    await openDetail(tester);
    final pack = data.packsOf(bean.id).first;
    await tapKey(tester, 'pack-edit-${pack.id}');
    await enterField(tester, 'weight', '300');
    await enterField(tester, 'roastDate', '2026-11-10');
    await tapKey(tester, 'form-save');
    final changed = data.packById(pack.id)!;
    expect(changed.sizeG, 300);
    expect(changed.remainingG, 300);
    expect(changed.roastDate.day, 10);
  });

  testWidgets('deleting the bean returns to the list without it', (
    tester,
  ) async {
    await openDetail(tester);
    await tapKey(tester, 'action-delete');
    expect(data.beans, isEmpty);
    expect(find.byKey(Key('bean-${bean.id}')), findsNothing);
  });
}
