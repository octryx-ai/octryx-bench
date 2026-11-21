import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/app/app_services.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';
import 'package:kaffee_begleiter/features/onboarding/domain/onboarding_gate.dart';
import 'package:kaffee_begleiter/features/today/presentation/today_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../form_helpers.dart';
import '../../helpers.dart';
import 'fake_flag_store.dart';

/// Pumps the app with an empty [AppData] and the flag missing; returns the data.
Future<AppData> pumpFlow(WidgetTester tester, {FakeFlagStore? store}) async {
  final data = AppData();
  await pumpApp(
    tester,
    data: data,
    height: tallViewport,
    services: AppServices(
      onboarding: OnboardingGate(store ?? FakeFlagStore(value: null)),
    ),
  );
  return data;
}

/// Taps the control labelled [label] and settles.
Future<void> tapLabel(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Goes from page 1 to page 4 without a grinder: Next, Next, then Later.
Future<void> toBeanPage(WidgetTester tester) async {
  await tapLabel(tester, 'Next');
  await tapLabel(tester, 'Next');
  await tapLabel(tester, 'Later');
}

/// Types [name] and [roaster] into the two text fields of page 4.
Future<void> typeBean(
  WidgetTester tester, {
  String name = 'Bohne 1',
  String roaster = 'Roestwerk',
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), roaster);
}

/// Saves Bohne 1 on page 4 with roast medium (default) and kind all-round.
Future<void> saveBean(WidgetTester tester) async {
  await typeBean(tester);
  final allRound = find.text('All-round');
  await tester.ensureVisible(allRound);
  await tester.tap(allRound);
  await tester.pumpAndSettle();
  await tapLabel(tester, 'Next');
}

void main() {
  validationTests();
  saveTests();
  finishTests();
}

/// Page 4 validation: each error is a line under its field, nothing is saved.
void validationTests() {
  testWidgets('an empty name shows the required line and saves nothing', (
    tester,
  ) async {
    final data = await pumpFlow(tester);
    await toBeanPage(tester);
    await typeBean(tester, name: '');
    await tapLabel(tester, 'Next');
    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Created: Bohne 1'), findsNothing);
    expect(data.beans, isEmpty);
  });

  testWidgets('an empty roaster shows the required line and saves nothing', (
    tester,
  ) async {
    final data = await pumpFlow(tester);
    await toBeanPage(tester);
    await typeBean(tester, roaster: '');
    await tapLabel(tester, 'Next');
    expect(find.text('Enter a roaster'), findsOneWidget);
    expect(find.text('Created: Bohne 1'), findsNothing);
    expect(data.beans, isEmpty);
  });
}

/// Saving Bohne 1 keeps page 4 with the created line and Let's go.
void saveTests() {
  testWidgets('saving Bohne 1 stays on page 4 and shows Let\'s go', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null);
    final data = await pumpFlow(tester, store: store);
    await toBeanPage(tester);
    await saveBean(tester);
    expect(find.text('All set'), findsOneWidget);
    expect(find.text('Created: Bohne 1'), findsOneWidget);
    expect(find.text("Let's go"), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    expect(find.byType(TodayScreen), findsNothing);
    expect(store.writeCount, 0);
    expect(data.beans, hasLength(1));
    final bean = data.beans.single;
    expect(bean.name, 'Bohne 1');
    expect(bean.roaster, 'Roestwerk');
    expect(bean.roastLevel, RoastLevel.medium);
    expect(bean.kind, BeanKind.allround);
    expect(data.packs, isEmpty);
  });

  testWidgets('Zurück to a saved page 4 creates nothing new', (tester) async {
    final data = await pumpFlow(tester);
    await toBeanPage(tester);
    await saveBean(tester);
    await tapLabel(tester, 'Back');
    expect(find.text('Your grinder'), findsOneWidget);
    await tapLabel(tester, 'Later');
    expect(find.text('Created: Bohne 1'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(data.beans, hasLength(1));
    expect(data.packs, isEmpty);
  });
}

/// Los geht's and Später finish the onboarding; a failed flag write keeps page 4.
void finishTests() {
  testWidgets(
    'Los geht\'s sets the flag and shows Bohne 1 under Ohne Packung',
    (tester) async {
      final store = FakeFlagStore(value: null);
      await pumpFlow(tester, store: store);
      await toBeanPage(tester);
      await saveBean(tester);
      await tapLabel(tester, "Let's go");
      expect(store.value, isTrue);
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.text('No pack yet'), findsOneWidget);
      expect(find.text('Add a pack'), findsOneWidget);
      expect(find.text('Bohne 1'), findsOneWidget);
    },
  );

  testWidgets('a failed flag write keeps page 4; Retry then shows Heute', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null, writeFailures: 1);
    final data = await pumpFlow(tester, store: store);
    await toBeanPage(tester);
    await saveBean(tester);
    await tapLabel(tester, "Let's go");
    expect(store.value, isNull);
    expect(find.text('Setting could not be saved'), findsOneWidget);
    expect(find.text('Created: Bohne 1'), findsOneWidget);
    expect(find.byType(TodayScreen), findsNothing);
    await tapLabel(tester, 'Retry');
    expect(store.value, isTrue);
    expect(store.writeCount, 2);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(data.beans, hasLength(1));
  });

  testWidgets('Später on page 4 finishes without creating a bean', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null);
    final data = await pumpFlow(tester, store: store);
    await toBeanPage(tester);
    await tapLabel(tester, 'Later');
    expect(store.value, isTrue);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(data.beans, isEmpty);
  });
}
