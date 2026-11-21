import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew.dart';
import 'package:kaffee_begleiter/features/brews/domain/brew_method.dart';

/// 16 November 2026.
final DateTime today = DateTime.utc(2026, 11, 16);

/// Medium roast espresso blend, rest 10 days, lead time 3 days.
Bean testBean({double? minStockG, int leadTimeDays = 3}) => Bean(
  id: 'b1',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  name: 'Kenya',
  roaster: 'R',
  roastLevel: RoastLevel.medium,
  kind: BeanKind.espressoBlend,
  minStockG: minStockG,
  leadTimeDays: leadTimeDays,
);

/// Pack of bean `b1` roasted on [roast] (`yyyy-MM-dd`).
Pack testPack(
  String id,
  String roast,
  double remaining, {
  bool opened = false,
}) => Pack(
  id: id,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  beanId: 'b1',
  roastDate: Pack.parseDate(roast),
  sizeG: 250,
  remainingG: remaining,
  openedAt: opened ? DateTime.utc(2026, 11, 10) : null,
);

/// Espresso brew of [doseG] (+ [purgeG]) at noon, [daysAgo] days before
/// [today].
Brew testBrew(
  double doseG, {
  int daysAgo = 0,
  double purgeG = 0,
  String packId = 'p1',
  String id = 'x',
}) => Brew(
  id: id,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  method: BrewMethod.espresso,
  machineId: 'm',
  grinderId: 'g',
  packId: packId,
  grindSetting: 10,
  doseG: doseG,
  purgeG: purgeG,
  startedAt: DateTime.utc(2026, 11, 16 - daysAgo, 12),
);
