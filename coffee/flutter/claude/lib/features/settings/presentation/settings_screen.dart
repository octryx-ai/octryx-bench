import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_choice_chips.dart';
import '../../../core/widgets/link_card.dart';
import '../../../core/widgets/page_body.dart';
import '../../water/presentation/water_format.dart';
import '../domain/hardness_unit.dart';
import 'data_section.dart';
import 'sources_section.dart';

/// Einstellungen: hardness unit, export, import, delete all data, the style
/// guide link and the sources list.
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final data = AppScope.of(context);
    return AppShell(
      section: AppSection.settings,
      title: l.settings,
      body: PageBody(
        children: [
          Text(l.hardnessUnitLabel, style: text.titleMedium),
          const SizedBox(height: Tokens.space8),
          AppChoiceChips<HardnessUnit>(
            keyPrefix: 'hardness-unit',
            labels: {
              for (final u in HardnessUnit.values)
                u: WaterFormat.hardnessUnit(l, u),
            },
            selected: data.hardnessUnit,
            onSelected: data.setHardnessUnit,
          ),
          const SizedBox(height: Tokens.space24),
          const DataSection(),
          const SizedBox(height: Tokens.space24),
          LinkCard(
            label: l.styleGuide,
            icon: Icons.palette,
            route: AppRoutes.styleGuide,
          ),
          const SizedBox(height: Tokens.space16),
          const SourcesSection(),
        ],
      ),
    );
  }
}
