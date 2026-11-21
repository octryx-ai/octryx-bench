import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_services.dart';
import 'package:kaffee_begleiter/core/theme/onboarding_tokens.dart';
import 'package:kaffee_begleiter/core/widgets/app_button.dart';
import 'package:kaffee_begleiter/features/onboarding/domain/onboarding_gate.dart';
import 'package:kaffee_begleiter/features/onboarding/presentation/onboarding_header.dart';
import 'package:kaffee_begleiter/features/onboarding/presentation/onboarding_progress.dart';
import 'package:kaffee_begleiter/features/today/presentation/today_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers.dart';
import 'fake_flag_store.dart';

/// Pumps the onboarding with the flag missing, so it starts on page 1.
Future<void> pumpPages(WidgetTester tester, {Locale? locale}) => pumpApp(
  tester,
  locale: locale ?? const Locale('en'),
  services: AppServices(onboarding: OnboardingGate(FakeFlagStore(value: null))),
);

/// Taps the control labelled [label] and settles.
Future<void> tapLabel(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Number of progress dots filled in the primary colour.
int filledDots(WidgetTester tester) {
  final scope = find.byType(OnboardingProgress);
  final primary = Theme.of(tester.element(scope)).colorScheme.primary;
  return tester
      .widgetList<DecoratedBox>(
        find.descendant(of: scope, matching: find.byType(DecoratedBox)),
      )
      .where((box) {
        final d = box.decoration;
        return d is BoxDecoration &&
            d.shape == BoxShape.circle &&
            d.color == primary;
      })
      .length;
}

void main() {
  pageOneTests();
  pageTwoTests();
  pageFourTests();
  pageTwoActionTests();
}

/// Page 1 (Willkommen): header, text, progress and buttons.
void pageOneTests() {
  testWidgets('page 1: Willkommen, 160 dp header, progress 1 of 4', (
    tester,
  ) async {
    await pumpPages(tester);
    expect(find.text('Welcome'), findsOneWidget);
    expect(
      find.text('Keep track of how your coffee turns out.'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(OnboardingHeader)).height,
      OnboardingTokens.headerHeight,
    );
    expect(find.text('1 of 4'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 1 of 4'), findsOneWidget);
    expect(filledDots(tester), 1);
    expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(OnboardingHeader),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).gradient != null,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('page 1: Next is the enabled primary button, no Back', (
    tester,
  ) async {
    await pumpPages(tester);
    expect(find.text('Next'), findsOneWidget);
    expect(
      tester.widget<AppButton>(find.byType(AppButton)).onPressed,
      isNotNull,
    );
    expect(find.text('Back'), findsNothing);
    expect(find.text('Skip'), findsOneWidget);
  });
}

/// Page 2 (Funktionen): the three functions, progress and navigation.
void pageTwoTests() {
  testWidgets('page 2 names exactly the three functions (EN)', (tester) async {
    await pumpPages(tester);
    await tapLabel(tester, 'Next');
    expect(find.text('What the app does'), findsOneWidget);
    expect(find.text('Log brews'), findsOneWidget);
    expect(find.text('Track beans and resting time'), findsOneWidget);
    expect(find.text('Get tips to improve'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(3));
  });

  testWidgets('page 2 names the three functions in German', (tester) async {
    await pumpPages(tester, locale: const Locale('de'));
    await tapLabel(tester, 'Weiter');
    expect(find.text('Das kann die App'), findsOneWidget);
    expect(find.text('Brühungen erfassen'), findsOneWidget);
    expect(find.text('Bohnen und Ruhezeit führen'), findsOneWidget);
    expect(find.text('Empfehlung zur Verbesserung'), findsOneWidget);
    expect(find.text('2 von 4'), findsOneWidget);
  });

  testWidgets(
    'page 2: progress 2 of 4 fills half the dots; Back, Weiter, Skip',
    (tester) async {
      await pumpPages(tester);
      await tapLabel(tester, 'Next');
      expect(find.text('2 of 4'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 2 of 4'), findsOneWidget);
      expect(filledDots(tester), 2);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('page 2: Back returns to page 1 with progress 1 of 4', (
    tester,
  ) async {
    await pumpPages(tester);
    await tapLabel(tester, 'Next');
    await tapLabel(tester, 'Back');
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('1 of 4'), findsOneWidget);
    expect(filledDots(tester), 1);
  });
}

/// Page 4 (finish): progress 4 of 4 and the buttons.
void pageFourTests() {
  testWidgets('page 4: progress 4 of 4 fills every dot; Back and Let\'s go', (
    tester,
  ) async {
    await pumpPages(tester);
    await tapLabel(tester, 'Next');
    await tapLabel(tester, 'Next');
    await tapLabel(tester, 'Later');
    expect(find.text('4 of 4'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 4 of 4'), findsOneWidget);
    expect(filledDots(tester), 4);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text("Let's go"), findsOneWidget);
  });
}

/// Page 2 actions (criterion 5): Weiter leads to page 3, Skip sets the flag and
/// shows Heute.
void pageTwoActionTests() {
  testWidgets('page 2: Weiter shows page 3 with the grinder form', (
    tester,
  ) async {
    await pumpPages(tester);
    await tapLabel(tester, 'Next');
    await tapLabel(tester, 'Next');
    expect(find.text('Your grinder'), findsOneWidget);
    expect(find.text('3 of 4'), findsOneWidget);
  });

  testWidgets('page 2: Skip sets the flag and shows Heute', (tester) async {
    final store = FakeFlagStore(value: null);
    await pumpApp(
      tester,
      services: AppServices(onboarding: OnboardingGate(store)),
    );
    await tapLabel(tester, 'Next');
    await tapLabel(tester, 'Skip');
    expect(store.value, isTrue);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('page 2 in German: Weiter shows Deine Mühle', (tester) async {
    await pumpPages(tester, locale: const Locale('de'));
    await tapLabel(tester, 'Weiter');
    await tapLabel(tester, 'Weiter');
    expect(find.text('Deine Mühle'), findsOneWidget);
  });
}
