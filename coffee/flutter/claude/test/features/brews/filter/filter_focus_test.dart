import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_sidebar.dart';
import 'package:kaffee_begleiter/core/widgets/app_button.dart';
import 'package:kaffee_begleiter/features/brews/presentation/filter/step_feedback.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers.dart';
import 'filter_test_helpers.dart';

void main() {
  const targets = [
    'Pour to 40 g',
    'Pour to 120 g',
    'Pour to 220 g',
    'Pour to 320 g',
  ];

  Future<void> after(WidgetTester t, int seconds) =>
      t.pump(Duration(seconds: seconds));

  testWidgets('AC3 targets run 40, 120, 220, 320 g in order', (tester) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await startFocus(tester);
    for (var i = 0; i < targets.length; i++) {
      expect(targetText(tester), targets[i]);
      if (i < targets.length - 1) await tapNext(tester);
    }
  });

  testWidgets('AC3 German targets read Giesse bis ... g', (tester) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data, locale: const Locale('de'));
    await startFocus(tester);
    expect(targetText(tester), 'Giesse bis 40 g');
    expect(find.text('Weiter'), findsOneWidget);
    expect(find.text('Abbrechen'), findsOneWidget);
    expect(find.text('bei 0:00'), findsOneWidget);
    await tapNext(tester);
    expect(targetText(tester), 'Giesse bis 120 g');
    expect(find.text('bei 0:45'), findsOneWidget);
    expect(find.text('Aufguss 1'), findsOneWidget);
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets('AC3 focus mode has no navigation, one primary button '
        'and large digits at $width', (tester) async {
      final s = await seedFilterData();
      await pumpApp(tester, data: s.data, width: width, height: 800);
      await goTo(tester, '/brews');
      await tester.tap(find.byKey(const Key('start-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('form-save')));
      await tester.pump();
      await tester.pump();
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(AppSidebar), findsNothing);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      final timer = tester.widget<Text>(find.byKey(const Key('focus-timer')));
      final target = tester.widget<Text>(find.byKey(const Key('focus-target')));
      expect(timer.style!.fontSize, greaterThanOrEqualTo(72));
      expect(target.style!.fontSize, greaterThanOrEqualTo(48));
      expect(timer.style!.fontFeatures, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the timer ticks from Start (fake async)', (tester) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await startFocus(tester);
    expect(find.text('00:00'), findsOneWidget);
    await after(tester, 5);
    expect(find.text('00:05'), findsOneWidget);
    await after(tester, 62);
    expect(find.text('01:07'), findsOneWidget);
  });

  testWidgets('Cancel in focus mode leaves the screen', (tester) async {
    final s = await seedFilterData();
    await pumpFilter(tester, s.data);
    await startFocus(tester);
    await tester.tap(find.byKey(const Key('focus-cancel')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(s.data.brews, isEmpty);
  });

  testWidgets('AC4 feedback fires once at each step end', (tester) async {
    final s = await seedFilterData();
    final fake = FakeFeedback();
    await pumpFilter(tester, s.data, feedback: fake);
    await startFocus(tester);
    await after(tester, 30);
    expect(fake.fired, 0);
    await after(tester, 16);
    expect(fake.fired, 1);
    await after(tester, 5);
    expect(fake.fired, 1);
    await tapNext(tester);
    await after(tester, 30);
    expect(fake.fired, 2);
    await tapNext(tester);
    await after(tester, 45);
    expect(fake.fired, 3);
    await tapNext(tester);
    await after(tester, 60);
    expect(fake.fired, 4);
  });

  testWidgets('AC4 web: visual flash for 300 ms and no haptics or sound', (
    tester,
  ) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final s = await seedFilterData();
    await pumpFilter(tester, s.data, feedback: const StepFeedback(web: true));
    await startFocus(tester);
    expect(find.byKey(const Key('step-flash')), findsNothing);
    await after(tester, 46);
    expect(find.byKey(const Key('step-flash')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 310));
    expect(find.byKey(const Key('step-flash')), findsNothing);
    expect(calls.where((c) => c.startsWith('HapticFeedback')), isEmpty);
    expect(calls.where((c) => c.contains('SystemSoundType.alert')), isEmpty);
  });

  testWidgets('AC4 mobile: haptic and alert sound, no flash', (tester) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add('${call.method} ${call.arguments}');
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final s = await seedFilterData();
    await pumpFilter(tester, s.data, feedback: const StepFeedback(web: false));
    await startFocus(tester);
    await after(tester, 46);
    expect(
      calls,
      contains('HapticFeedback.vibrate HapticFeedbackType.mediumImpact'),
    );
    expect(calls, contains('SystemSound.play SystemSoundType.alert'));
    expect(find.byKey(const Key('step-flash')), findsNothing);
  });
}
