import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/app/app_services.dart';
import 'package:kaffee_begleiter/app/kaffee_app.dart';

/// Sets the logical viewport of the test window.
void setViewport(WidgetTester tester, double width, [double height = 800]) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);
}

/// Pumps the whole app in [locale] and [brightness] at [route].
Future<void> pumpApp(
  WidgetTester tester, {
  double width = 390,
  double height = 800,
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  AppData? data,
  AppServices? services,
}) async {
  setViewport(tester, width, height);
  tester.platformDispatcher.localesTestValue = [locale];
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(KaffeeApp(data: data, services: services));
  await tester.pumpAndSettle();
}

/// Navigates the running app to [route].
Future<void> goTo(WidgetTester tester, String route) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  nav.pushNamed(route);
  // The style guide shows an endless spinner, so pumpAndSettle would time out.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
