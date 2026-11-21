import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_bottom_bar.dart';
import 'package:kaffee_begleiter/app/app_services.dart';
import 'package:kaffee_begleiter/app/app_rail.dart';
import 'package:kaffee_begleiter/app/app_shell.dart';
import 'package:kaffee_begleiter/app/app_sidebar.dart';
import 'package:kaffee_begleiter/core/widgets/app_button.dart';
import 'package:kaffee_begleiter/features/onboarding/domain/onboarding_gate.dart';

import '../../helpers.dart';
import 'fake_flag_store.dart';

/// Pumps the app with the onboarding flag missing, so it starts on page 1.
Future<void> pumpOnboarding(
  WidgetTester tester, {
  double width = 390,
  double height = 800,
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
}) => pumpApp(
  tester,
  width: width,
  height: height,
  locale: locale,
  brightness: brightness,
  services: AppServices(onboarding: OnboardingGate(FakeFlagStore(value: null))),
);

void _widthTests() {
  group('layout', () {
    for (final width in [390.0, 1280.0]) {
      testWidgets('at $width dp: centred column of at most 480 dp', (
        tester,
      ) async {
        await pumpOnboarding(tester, width: width);
        expect(tester.takeException(), isNull);
        final column = tester.getSize(
          find.byKey(const Key('onboarding-column')),
        );
        expect(column.width, lessThanOrEqualTo(480));
        expect(column.width, width < 480 ? width : 480);
        final left = tester
            .getTopLeft(find.byKey(const Key('onboarding-column')))
            .dx;
        expect(left + column.width / 2, closeTo(width / 2, 0.5));
      });

      testWidgets('at $width dp: nothing is cut off, no horizontal scroll', (
        tester,
      ) async {
        await pumpOnboarding(tester, width: width);
        expect(tester.takeException(), isNull);
        final title = tester.getRect(find.text('Welcome'));
        final text = tester.getRect(
          find.text('Keep track of how your coffee turns out.'),
        );
        expect(title.left, greaterThanOrEqualTo(0));
        expect(title.right, lessThanOrEqualTo(width));
        expect(text.right, lessThanOrEqualTo(width));
        final horizontal = find.byWidgetPredicate(
          (w) =>
              w is Scrollable &&
              (w.axisDirection == AxisDirection.left ||
                  w.axisDirection == AxisDirection.right),
        );
        expect(horizontal, findsNothing);
        final singleChild = find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        );
        expect(singleChild, findsNothing);
      });

      testWidgets('at $width dp: no bottom bar, rail or sidebar', (
        tester,
      ) async {
        await pumpOnboarding(tester, width: width);
        expect(find.byType(AppShell), findsNothing);
        expect(find.byType(AppBottomBar), findsNothing);
        expect(find.byType(AppRail), findsNothing);
        expect(find.byType(AppSidebar), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
      });
    }
  });
}

void _controlTests() {
  group('layout', () {
    testWidgets('touch targets are at least 48 dp', (tester) async {
      await pumpOnboarding(tester, width: 390);
      final skip = tester.getSize(find.widgetWithText(TextButton, 'Skip'));
      expect(skip.width, greaterThanOrEqualTo(48));
      expect(skip.height, greaterThanOrEqualTo(48));
      final next = tester.getSize(find.byType(AppButton));
      expect(next.width, greaterThanOrEqualTo(48));
      expect(next.height, greaterThanOrEqualTo(48));
    });

    testWidgets('actions stay inside the viewport at 390 x 844', (
      tester,
    ) async {
      await pumpOnboarding(tester, width: 390, height: 844);
      final skip = tester.getRect(find.widgetWithText(TextButton, 'Skip'));
      final next = tester.getRect(find.byType(AppButton));
      expect(skip.bottom, lessThanOrEqualTo(844));
      expect(next.right, lessThanOrEqualTo(390));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Next is enabled on page 1, no Back button there', (
      tester,
    ) async {
      await pumpOnboarding(tester);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNotNull,
      );
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('dark theme renders without errors', (tester) async {
      await pumpOnboarding(tester, brightness: Brightness.dark);
      expect(tester.takeException(), isNull);
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}

void _textTests() {
  group('texts', () {
    testWidgets('English texts and semantics labels', (tester) async {
      await pumpOnboarding(tester);
      for (final t in [
        'Welcome',
        'Keep track of how your coffee turns out.',
        'Skip',
        'Next',
        '1 of 4',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.bySemanticsLabel('Step 1 of 4'), findsOneWidget);
      expect(find.bySemanticsLabel('Skip'), findsOneWidget);
    });

    testWidgets('German texts and semantics labels', (tester) async {
      await pumpOnboarding(tester, locale: const Locale('de', 'CH'));
      for (final t in [
        'Willkommen',
        'Halte fest, wie dein Kaffee gelingt.',
        'Überspringen',
        'Weiter',
        '1 von 4',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.bySemanticsLabel('Schritt 1 von 4'), findsOneWidget);
      expect(find.bySemanticsLabel('Überspringen'), findsOneWidget);
    });

    testWidgets('German error banner texts', (tester) async {
      final store = FakeFlagStore(value: null, writeFailures: 1);
      await pumpApp(
        tester,
        locale: const Locale('de'),
        services: AppServices(onboarding: OnboardingGate(store)),
      );
      await tester.tap(find.text('Überspringen'));
      await tester.pumpAndSettle();
      expect(
        find.text('Einstellung konnte nicht gespeichert werden'),
        findsOneWidget,
      );
      expect(find.text('Erneut versuchen'), findsOneWidget);
    });
  });
}

void main() {
  _widthTests();
  _controlTests();
  _textTests();

  testWidgets('skip button shows the focus ring when focused', (tester) async {
    await pumpOnboarding(tester);
    expect(find.byKey(const Key('focus-ring')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.byKey(const Key('focus-ring')), findsOneWidget);
  });
}
