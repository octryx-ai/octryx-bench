import 'dart:io';

import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/core/data/clock.dart';
import 'package:kaffee_begleiter/core/rules/rule_asset_loader.dart';
import 'package:kaffee_begleiter/core/rules/rule_set.dart';
import 'package:kaffee_begleiter/features/beans/domain/rest_calculator.dart';
import 'package:kaffee_begleiter/features/water/domain/water_checker.dart';

/// Builds a [WaterChecker] from `assets/water_rules.json` on disk.
Future<WaterChecker> loadTestChecker() async => WaterChecker(
  RuleSet(
    RuleAssetLoader.parse(File(WaterChecker.assetName).readAsStringSync()),
  ),
);

/// Builds a [RestCalculator] from `assets/rest_rules.json` on disk.
RestCalculator loadTestRest() => RestCalculator(
  RuleSet(
    RuleAssetLoader.parse(File(RestCalculator.assetName).readAsStringSync()),
  ),
);

/// Builds an empty [AppData] using the real water and rest rules and an
/// optional [clock].
Future<AppData> loadTestAppData({Clock? clock}) async => AppData(
  checker: await loadTestChecker(),
  rest: loadTestRest(),
  clock: clock,
);
