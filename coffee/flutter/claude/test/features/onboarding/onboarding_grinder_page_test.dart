import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/app/app_services.dart';
import 'package:kaffee_begleiter/features/equipment/domain/finer_direction.dart';
import 'package:kaffee_begleiter/features/onboarding/domain/onboarding_gate.dart';
import 'package:kaffee_begleiter/features/today/presentation/today_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers.dart';
import 'fake_flag_store.dart';

/// Pumps the app with an empty [data] and the flag missing; returns the data.
Future<AppData> pumpFlow(WidgetTester tester, {FakeFlagStore? store}) async {
  final data = AppData();
  await pumpApp(
    tester,
    data: data,
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

/// Goes from page 1 to the grinder page (page 3).
Future<void> toGrinderPage(WidgetTester tester) async {
  await tapLabel(tester, 'Next');
  await tapLabel(tester, 'Next');
}

/// Types the grinder values into the five fields of page 3.
Future<void> typeGrinder(
  WidgetTester tester, {
  String name = 'M1',
  String min = '1',
  String max = '30',
  String step = '0.5',
  String dead = '2.5',
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), min);
  await tester.enterText(fields.at(2), max);
  await tester.enterText(fields.at(3), step);
  await tester.enterText(fields.at(4), dead);
}

/// Types M1 and saves it with Weiter, which lands on page 4.
Future<void> saveM1(WidgetTester tester) async {
  await toGrinderPage(tester);
  await typeGrinder(tester);
  await tapLabel(tester, 'Next');
}

void main() {
  validationTests();
  saveTests();
  laterAndSessionTests();
}

/// Page 3 validation: each error is a line under its field, nothing is saved.
void validationTests() {
  testWidgets('an empty name shows the required line and saves nothing', (
    tester,
  ) async {
    final data = await pumpFlow(tester);
    await toGrinderPage(tester);
    await typeGrinder(tester, name: '');
    await tapLabel(tester, 'Next');
    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Your grinder'), findsOneWidget);
    expect(data.grinders, isEmpty);
  });

  testWidgets('a scale step of 0 shows the step error', (tester) async {
    final data = await pumpFlow(tester);
    await toGrinderPage(tester);
    await typeGrinder(tester, step: '0');
    await tapLabel(tester, 'Next');
    expect(find.text('Step must be greater than 0'), findsOneWidget);
    expect(data.grinders, isEmpty);
  });

  testWidgets('a maximum not above the minimum shows the scale error', (
    tester,
  ) async {
    final data = await pumpFlow(tester);
    await toGrinderPage(tester);
    await typeGrinder(tester, min: '30', max: '1');
    await tapLabel(tester, 'Next');
    expect(
      find.text('Maximum must be greater than the minimum'),
      findsOneWidget,
    );
    expect(data.grinders, isEmpty);
  });

  testWidgets('a dead space above 100 shows the range error', (tester) async {
    final data = await pumpFlow(tester);
    await toGrinderPage(tester);
    await typeGrinder(tester, dead: '150');
    await tapLabel(tester, 'Next');
    expect(find.textContaining('Enter a value between'), findsOneWidget);
    expect(data.grinders, isEmpty);
  });
}

/// Saving M1 creates one grinder with the entered values and shows page 4.
void saveTests() {
  testWidgets('saving M1 creates one grinder and goes to page 4', (
    tester,
  ) async {
    final data = await pumpFlow(tester);
    await saveM1(tester);
    expect(find.text('All set'), findsOneWidget);
    expect(find.text('Created: M1'), findsOneWidget);
    expect(data.grinders, hasLength(1));
    final grinder = data.grinders.single;
    expect(grinder.name, 'M1');
    expect(grinder.scaleMin, 1);
    expect(grinder.scaleMax, 30);
    expect(grinder.scaleStep, 0.5);
    expect(grinder.deadSpaceG, 2.5);
  });

  testWidgets('the finer direction chosen on page 3 is saved', (tester) async {
    final data = await pumpFlow(tester);
    await toGrinderPage(tester);
    await typeGrinder(tester);
    final up = find.text('Up (higher is finer)');
    await tester.ensureVisible(up);
    await tester.tap(up);
    await tester.pumpAndSettle();
    await tapLabel(tester, 'Next');
    expect(data.grinders.single.finerDirection, FinerDirection.up);
  });

  testWidgets('back to a saved page 3 shows Created and creates nothing new', (
    tester,
  ) async {
    final data = await pumpFlow(tester);
    await saveM1(tester);
    await tapLabel(tester, 'Back');
    expect(find.text('Created: M1'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tapLabel(tester, 'Next');
    expect(find.text('All set'), findsOneWidget);
    expect(data.grinders, hasLength(1));
  });

  testWidgets('completing shows the grinder under Ausrüstung', (tester) async {
    final data = await pumpFlow(tester);
    await saveM1(tester);
    await tapLabel(tester, "Let's go");
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(data.machines, isEmpty);
    expect(data.waterProfiles, isEmpty);
    await goTo(tester, '/equipment');
    await tester.pumpAndSettle();
    expect(find.textContaining('M1'), findsWidgets);
    expect(find.textContaining('2.5 g'), findsWidgets);
  });
}

/// Später creates nothing; a grinder saved before Skip stays in the session.
void laterAndSessionTests() {
  testWidgets('Später on page 3 creates no grinder and goes to page 4', (
    tester,
  ) async {
    final data = await pumpFlow(tester);
    await toGrinderPage(tester);
    await tapLabel(tester, 'Later');
    expect(find.text('All set'), findsOneWidget);
    expect(find.textContaining('Created:'), findsNothing);
    expect(data.grinders, isEmpty);
  });

  testWidgets('a grinder saved before Skip stays in the session, not doubled', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null);
    final data = await pumpFlow(tester, store: store);
    await saveM1(tester);
    await tapLabel(tester, 'Skip');
    expect(store.value, isTrue);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(data.grinders, hasLength(1));
  });
}
