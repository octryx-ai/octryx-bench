import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:kaffee_begleiter/app/app_services.dart';
import 'package:kaffee_begleiter/core/widgets/app_button.dart';
import 'package:kaffee_begleiter/features/onboarding/domain/onboarding_gate.dart';
import 'package:kaffee_begleiter/features/today/presentation/today_screen.dart';

import '../../helpers.dart';
import 'fake_flag_store.dart';

/// Pumps the onboarding with [store] as the flag store.
Future<void> pumpWith(WidgetTester tester, FakeFlagStore store) =>
    pumpApp(tester, services: AppServices(onboarding: OnboardingGate(store)));

/// Taps Next [times] times, settling after each tap.
Future<void> tapNext(WidgetTester tester, int times) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }
}

/// Fills the grinder form with a valid grinder called [name].
Future<void> fillGrinder(WidgetTester tester, String name) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), '1');
  await tester.enterText(fields.at(2), '30');
  await tester.enterText(fields.at(3), '0.5');
  await tester.enterText(fields.at(4), '2.5');
}

void main() {
  navigationTests();
  completionTests();
  laterTests();
}

void navigationTests() {
  testWidgets('Next on page 1 opens page 2 with the three functions', (
    tester,
  ) async {
    await pumpWith(tester, FakeFlagStore(value: null));
    await tapNext(tester, 1);
    expect(find.text('What the app does'), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
    expect(find.text('2 of 4'), findsOneWidget);
    expect(find.text('Log brews'), findsOneWidget);
    expect(find.text('Track beans and resting time'), findsOneWidget);
    expect(find.text('Get tips to improve'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('page 2 Weiter is enabled; Back returns to page 1', (
    tester,
  ) async {
    await pumpWith(tester, FakeFlagStore(value: null));
    await tapNext(tester, 1);
    expect(
      tester.widget<AppButton>(find.byType(AppButton)).onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('1 of 4'), findsOneWidget);
    expect(find.text('What the app does'), findsNothing);
  });
}

void completionTests() {
  testWidgets('walks all four pages, creates the grinder and completes', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null);
    await pumpWith(tester, store);
    await tapNext(tester, 2);
    expect(find.text('Your grinder'), findsOneWidget);
    expect(find.text('3 of 4'), findsOneWidget);
    await fillGrinder(tester, 'M1');
    await tapNext(tester, 1);
    expect(find.text('All set'), findsOneWidget);
    expect(find.text('Created: M1'), findsOneWidget);
    expect(find.text('4 of 4'), findsOneWidget);
    await tester.tap(find.text("Let's go"));
    await tester.pumpAndSettle();
    expect(store.value, isTrue);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('an empty grinder form shows the error and stays on page 3', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null);
    await pumpWith(tester, store);
    await tapNext(tester, 2);
    await tapNext(tester, 1);
    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Your grinder'), findsOneWidget);
    expect(find.text('All set'), findsNothing);
    expect(store.writeCount, 0);
  });

  testWidgets('Skip on page 2 writes the flag and shows Heute', (tester) async {
    final store = FakeFlagStore(value: null);
    await pumpWith(tester, store);
    await tapNext(tester, 1);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(store.value, isTrue);
    expect(find.byType(TodayScreen), findsOneWidget);
  });
}

void laterTests() {
  testWidgets('Später on page 3 goes to page 4 without a grinder', (
    tester,
  ) async {
    await pumpWith(tester, FakeFlagStore(value: null));
    await tapNext(tester, 2);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('All set'), findsOneWidget);
    expect(find.textContaining('Created:'), findsNothing);
  });

  testWidgets('Back from page 4 returns to the grinder page', (tester) async {
    await pumpWith(tester, FakeFlagStore(value: null));
    await tapNext(tester, 2);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Your grinder'), findsOneWidget);
  });
}
