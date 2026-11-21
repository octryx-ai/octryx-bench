import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_gradient.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';
import 'package:kaffee_begleiter/core/widgets/empty_state.dart';
import 'package:kaffee_begleiter/features/beans/presentation/bean_image.dart';

import '../../form_helpers.dart';
import '../../helpers.dart';
import 'bean_test_helpers.dart';

void main() {
  late AppData data;
  setUp(() async => data = await beanTestData());

  Future<void> openList(WidgetTester tester, {Locale? locale}) async {
    await pumpApp(
      tester,
      data: data,
      height: tallViewport,
      locale: locale ?? const Locale('en'),
    );
    await goTo(tester, '/beans');
  }

  testWidgets('AC6 empty state in English', (tester) async {
    await openList(tester);
    expect(find.text('No beans yet'), findsOneWidget);
    expect(find.text('Add your first bean.'), findsOneWidget);
    expect(find.text('Add bean'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(EmptyState),
        matching: find.byIcon(Icons.coffee),
      ),
      findsOneWidget,
    );
  });

  testWidgets('AC6 empty state in German and the button opens the form', (
    tester,
  ) async {
    await openList(tester, locale: const Locale('de'));
    expect(find.text('Noch keine Bohnen'), findsOneWidget);
    expect(find.text('Lege deine erste Bohne an.'), findsOneWidget);
    expect(find.text('Bohne hinzufügen'), findsOneWidget);
    await tester.tap(find.text('Bohne hinzufügen'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('field-name')), findsOneWidget);
  });

  testWidgets('AC3 chips: ready, resting 3 days, too old (en)', (tester) async {
    await seedBean(data, 'Rested', roasts: ['2026-11-04']);
    await seedBean(data, 'Fresh', roasts: ['2026-11-09']);
    await seedBean(data, 'Stale', roasts: ['2026-10-02']);
    await openList(tester);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Resting, 3 days left'), findsOneWidget);
    expect(find.text('Too old'), findsOneWidget);
  });

  testWidgets('AC3 chips in German', (tester) async {
    await seedBean(data, 'Fresh', roasts: ['2026-11-09']);
    await seedBean(data, 'Rested', roasts: ['2026-11-04']);
    await openList(tester, locale: const Locale('de'));
    expect(find.text('Ruht noch 3 Tage'), findsOneWidget);
    expect(find.text('Bereit'), findsOneWidget);
  });

  testWidgets('AC8 filter is ready earlier than espresso', (tester) async {
    await seedBean(
      data,
      'Filter bean',
      kind: BeanKind.filter,
      roasts: ['2026-11-10'],
    );
    await seedBean(data, 'Espresso bean', roasts: ['2026-11-10']);
    await openList(tester);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Resting, 4 days left'), findsOneWidget);
    final filter = find.byKey(Key('bean-${data.beans.first.id}'));
    expect(
      find.descendant(of: filter, matching: find.text('Ready')),
      findsOneWidget,
    );
  });

  testWidgets('AC4 list order by earliest ready date with two roasters', (
    tester,
  ) async {
    final late = await seedBean(
      data,
      'Late',
      roaster: 'Roaster A',
      roasts: ['2026-11-10'],
    );
    final two = await seedBean(
      data,
      'Two packs',
      roaster: 'Roaster B',
      roasts: ['2026-11-12', '2026-11-01'],
    );
    final filter = await seedBean(
      data,
      'Filter',
      roaster: 'Roaster B',
      kind: BeanKind.filter,
      roasts: ['2026-11-05'],
    );
    final none = await seedBean(data, 'No pack', roasts: []);
    await openList(tester);
    double top(String id) => tester.getTopLeft(find.byKey(Key('bean-$id'))).dy;
    final order = [filter, two, late, none];
    for (var i = 1; i < order.length; i++) {
      expect(top(order[i].id), greaterThan(top(order[i - 1].id)));
    }
    expect(find.text('Roaster A'), findsOneWidget);
    expect(find.text('Roaster B'), findsNWidgets(2));
    expect(find.text('No pack'), findsNWidgets(2));
  });

  testWidgets('card shows height 88, gap 12 and total grams', (tester) async {
    final a = await seedBean(
      data,
      'Alpha',
      roasts: ['2026-11-04', '2026-11-05'],
    );
    final b = await seedBean(data, 'Beta', roasts: ['2026-11-06']);
    await openList(tester);
    final ra = tester.getRect(find.byKey(Key('bean-${a.id}')));
    final rb = tester.getRect(find.byKey(Key('bean-${b.id}')));
    expect(ra.height, 88);
    expect(rb.top - ra.bottom, 12);
    expect(find.text('500 g'), findsOneWidget);
    expect(find.text('250 g'), findsOneWidget);
  });

  testWidgets('AC5 neighbouring cards differ in hue, dots follow roast', (
    tester,
  ) async {
    expect(
      BeanGradient.forName('Ethiopia Guji').hue,
      isNot(BeanGradient.forName('Brasil Santos').hue),
    );
    final light = await seedBean(
      data,
      'Ethiopia Guji',
      level: RoastLevel.light,
      roasts: ['2026-11-01'],
    );
    final dark = await seedBean(
      data,
      'Brasil Santos',
      level: RoastLevel.dark,
      roasts: ['2026-11-02'],
    );
    await openList(tester);
    Finder dots(String id, String kind) => find.descendant(
      of: find.byKey(Key('bean-$id')),
      matching: find.byKey(Key('roast-dot-$kind')),
    );
    expect(dots(light.id, 'filled'), findsNWidgets(1));
    expect(dots(light.id, 'empty'), findsNWidgets(3));
    expect(dots(dark.id, 'filled'), findsNWidgets(4));
    expect(dots(dark.id, 'empty'), findsNothing);
    final images = tester
        .widgetList<BeanImage>(find.byType(BeanImage))
        .toList();
    expect(images, hasLength(2));
    final colors = [
      for (final e in find.byType(BeanImage).evaluate())
        _gradientColors(tester, find.byWidget(e.widget)),
    ];
    expect(colors[0], isNot(colors[1]));
    expect(tester.getSize(find.byType(BeanImage).first), const Size(56, 56));
    expect(
      find.descendant(
        of: find.byType(BeanImage),
        matching: find.byIcon(Icons.coffee),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('tapping a card opens the detail', (tester) async {
    final bean = await seedBean(data, 'Open me');
    await openList(tester);
    await tapKey(tester, 'bean-${bean.id}');
    expect(find.text('Packs'), findsOneWidget);
  });
}

List<Color> _gradientColors(WidgetTester tester, Finder image) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: image, matching: find.byType(DecoratedBox)).first,
  );
  final gradient =
      (box.decoration as BoxDecoration).gradient! as LinearGradient;
  return gradient.colors;
}
