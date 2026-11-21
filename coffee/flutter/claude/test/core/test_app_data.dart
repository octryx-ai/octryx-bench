import 'dart:io';

import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/core/rules/rule_asset_loader.dart';
import 'package:kaffee_begleiter/core/rules/rule_set.dart';
import 'package:kaffee_begleiter/features/water/domain/water_checker.dart';

/// Builds a [WaterChecker] from `assets/water_rules.json` on disk.
Future<WaterChecker> loadTestChecker() async => WaterChecker(
  RuleSet(
    RuleAssetLoader.parse(File(WaterChecker.assetName).readAsStringSync()),
  ),
);

/// Builds an empty [AppData] whose checker uses the real water rules.
Future<AppData> loadTestAppData() async =>
    AppData(checker: await loadTestChecker());
