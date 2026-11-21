import 'package:material_ui/material_ui.dart';

import 'app/app_data.dart';
import 'app/kaffee_app.dart';
import 'core/rules/bundle_rule_source.dart';
import 'features/water/domain/water_checker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final checker = await WaterChecker.load(BundleRuleSource());
  runApp(KaffeeApp(data: AppData(checker: checker)));
}
