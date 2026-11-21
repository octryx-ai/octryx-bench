import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_services.dart';
import 'package:kaffee_begleiter/features/onboarding/domain/onboarding_gate.dart';
import 'package:kaffee_begleiter/features/onboarding/presentation/onboarding_screen.dart';
import 'package:kaffee_begleiter/features/today/presentation/today_screen.dart';

import '../../helpers.dart';
import 'fake_flag_store.dart';

/// Pumps the app with [store] as the onboarding flag store.
Future<void> pumpWithStore(WidgetTester tester, FakeFlagStore store) {
  return pumpApp(
    tester,
    services: AppServices(onboarding: OnboardingGate(store)),
  );
}

/// Disposes the running app, so the next pump starts it from scratch like a
/// new launch or a reload.
Future<void> restartApp(WidgetTester tester, FakeFlagStore store) async {
  await tester.pumpWidget(const SizedBox());
  await pumpWithStore(tester, store);
}

void _startTests() {
  testWidgets('flag missing shows onboarding page 1 even with data', (
    tester,
  ) async {
    await pumpWithStore(tester, FakeFlagStore(value: null));
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(TodayScreen), findsNothing);
  });

  testWidgets('flag false shows onboarding page 1', (tester) async {
    await pumpWithStore(tester, FakeFlagStore(value: false));
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(TodayScreen), findsNothing);
  });

  testWidgets('flag true starts with Heute', (tester) async {
    await pumpWithStore(tester, FakeFlagStore(value: true));
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('read error of the flag starts with Heute, no loop', (
    tester,
  ) async {
    await pumpWithStore(
      tester,
      FakeFlagStore(value: null, readError: StateError('read failed')),
    );
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
  });
}

void _skipTests() {
  testWidgets('no write happens before skip', (tester) async {
    final store = FakeFlagStore(value: null);
    await pumpWithStore(tester, store);
    expect(store.writeCount, 0);
    expect(store.value, isNull);
  });

  testWidgets('skip writes the flag and shows Heute without confirmation', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null);
    await pumpWithStore(tester, store);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(store.value, isTrue);
    expect(store.writeCount, 1);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
  });

  testWidgets('a second start after skip shows Heute', (tester) async {
    final store = FakeFlagStore(value: null);
    await pumpWithStore(tester, store);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await restartApp(tester, store);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
  });
}

void _bannerTests() {
  testWidgets('a failed write keeps page 1 and shows the retry banner', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null, writeFailures: 1);
    await pumpWithStore(tester, store);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(store.value, isNull);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(TodayScreen), findsNothing);
    expect(find.text('Setting could not be saved'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('retry after a successful write shows Heute', (tester) async {
    final store = FakeFlagStore(value: null, writeFailures: 1);
    await pumpWithStore(tester, store);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(store.writeCount, 2);
    expect(store.value, isTrue);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
  });

  testWidgets('system back on page 1 does not leave onboarding', (
    tester,
  ) async {
    final store = FakeFlagStore(value: null);
    await pumpWithStore(tester, store);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    expect(store.writeCount, 0);
  });
}

void main() {
  _startTests();
  _skipTests();
  _bannerTests();
}
