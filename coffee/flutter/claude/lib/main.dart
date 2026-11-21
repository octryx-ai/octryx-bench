import 'package:material_ui/material_ui.dart';

import 'app/app_data.dart';
import 'app/kaffee_app.dart';
import 'core/rules/bundle_rule_source.dart';
import 'core/rules/rule_asset_loader.dart';
import 'features/beans/domain/rest_calculator.dart';
import 'features/water/domain/water_checker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final checker = await WaterChecker.load(BundleRuleSource());
  final rest = RestCalculator(
    await RuleAssetLoader(BundleRuleSource()).loadSet(RestCalculator.assetName),
  );
  final loader = RuleAssetLoader(BundleRuleSource());
  final brewRules = await loader.loadSet('assets/brew_rules.json');
  final careRules = await loader.loadSet('assets/care_rules.json');
  runApp(
    KaffeeApp(
      data: AppData(
        checker: checker,
        rest: rest,
        brewRules: brewRules,
        careRules: careRules,
      ),
    ),
  );
}
