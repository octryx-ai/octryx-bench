import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/core/data/fixed_clock.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';

import '../../core/test_app_data.dart';
import '../../form_helpers.dart';

/// Test "today": 16 November 2026.
final DateTime today = DateTime.utc(2026, 11, 16);

/// App data with the clock fixed on [today] (midday, safe in any timezone).
Future<AppData> beanTestData() =>
    loadTestAppData(clock: FixedClock(DateTime.utc(2026, 11, 16, 12)));

/// Adds a bean and one pack roasted on [roast] (`yyyy-MM-dd`) per entry.
Future<Bean> seedBean(
  AppData data,
  String name, {
  String roaster = 'Roaster',
  RoastLevel level = RoastLevel.medium,
  BeanKind kind = BeanKind.espressoBlend,
  List<String> roasts = const ['2026-11-04'],
  double sizeG = 250,
}) async {
  final bean = await data.addBean(
    name: name,
    roaster: roaster,
    roastLevel: level,
    kind: kind,
  );
  for (final r in roasts) {
    await data.addPack(
      beanId: bean.id,
      roastDate: Pack.parseDate(r),
      sizeG: sizeG,
    );
  }
  return bean;
}

/// Fills the bean form (new bean) with a name, weight and roast date text.
Future<void> fillBeanForm(
  WidgetTester tester, {
  required String name,
  required String weight,
  String? roastDate,
}) async {
  await enterField(tester, 'name', name);
  await enterField(tester, 'weight', weight);
  if (roastDate != null) await enterField(tester, 'roastDate', roastDate);
}
