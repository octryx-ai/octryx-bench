import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/app/app_router.dart';
import 'package:kaffee_begleiter/app/app_routes.dart';
import 'package:kaffee_begleiter/app/app_scope.dart';
import 'package:kaffee_begleiter/core/theme/app_theme.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';
import 'package:kaffee_begleiter/features/brews/domain/taste.dart';
import 'package:kaffee_begleiter/features/brews/presentation/filter/filter_screen.dart';
import 'package:kaffee_begleiter/features/brews/presentation/filter/step_feedback.dart';
import 'package:kaffee_begleiter/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers.dart';
import '../../beans/bean_test_helpers.dart';
import '../brew_test_helpers.dart';

/// [StepFeedback] that only counts how often it fired.
class FakeFeedback extends StepFeedback {
  /// Creates the counter; [web] decides whether the flash shows.
  FakeFeedback({super.web});

  /// Number of cues.
  int fired = 0;

  @override
  Future<void> fire() async => fired++;
}

/// Seeded data plus a ready filter bean (roasted 4 Nov 2026).
Future<BrewSeed> seedFilterData({
  List<String> roasts = const ['2026-11-04'],
}) async {
  final s = await seedBrewData();
  await seedBean(s.data, 'Ethiopia', kind: BeanKind.filter, roasts: roasts);
  return s;
}

/// Pumps the guided filter screen alone (so a fake [feedback] can be
/// injected); route names resolve through the app router.
Future<void> pumpFilter(
  WidgetTester tester,
  AppData data, {
  StepFeedback feedback = const StepFeedback(web: true),
  Locale locale = const Locale('en'),
  double width = 390,
  double height = 900,
  String? sourceBrewId,
}) async {
  setViewport(tester, width, height);
  await tester.pumpWidget(
    AppScope(
      data: data,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: FilterScreen(feedback: feedback, sourceBrewId: sourceBrewId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Taps Start and lets the timer take its first (zero) tick.
Future<void> startFocus(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('form-save')));
  await tester.pump();
  await tester.pump();
}

/// Taps "Next" and rebuilds.
Future<void> tapNext(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('focus-next')));
  await tester.pump();
}

/// Text of the focus target (e.g. `Pour to 40 g`).
String targetText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('focus-target'))).data!;

/// Logs a V60 brew of 20 g at 1:16 on the seeded equipment.
Future<Brew> filterBrew(
  BrewSeed s, {
  double setting = 20,
  int drawdown = 255,
  Taste? taste = Taste.bitter,
  int? rating,
}) {
  final recipe = s.data.filterRecipes.recipe(doseG: 20, ratio: 16);
  return s.data.addBrew(
    method: BrewMethod.v60,
    grinderId: s.grinder.id,
    packId: s.data.filterPackSuggestions().first.pack.id,
    grindSetting: setting,
    doseG: 20,
    waterTotalG: recipe.waterG,
    bloomG: recipe.bloomG,
    pours: recipe.pours,
    drawdownS: drawdown,
    waterProfileId: s.water.id,
    taste: taste,
    rating: rating,
    startedAt: DateTime.utc(2026, 11, 15),
  );
}

/// Route of the filter screen, for navigation checks.
const String filterRoute = AppRoutes.filter;
