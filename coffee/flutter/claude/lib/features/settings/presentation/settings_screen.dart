import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/rules/rule_entry.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_choice_chips.dart';
import '../../../core/widgets/link_card.dart';
import '../../../core/widgets/page_body.dart';
import '../../../core/widgets/rule_source_label.dart';
import '../../water/presentation/water_format.dart';
import '../domain/hardness_unit.dart';

/// Einstellungen: hardness unit; export and import follow in a later story.
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  static const _demoEntry = RuleEntry(
    key: 'demo',
    value: 0,
    source: 'none',
    retrieved: '2026-11-16',
  );

  Widget _soonCard(BuildContext context, String title, Key key) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Tokens.space12),
      child: AppCard(
        key: key,
        semanticLabel: '$title: ${context.l10n.comingSoon}',
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Tokens.touchTarget),
          child: Row(
            children: [
              Expanded(child: Text(title, style: text.titleMedium)),
              Text(context.l10n.comingSoon, style: text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

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
          _soonCard(context, l.exportData, const Key('settings-export')),
          _soonCard(context, l.importData, const Key('settings-import')),
          LinkCard(
            label: l.styleGuide,
            icon: Icons.palette,
            route: AppRoutes.styleGuide,
          ),
          const SizedBox(height: Tokens.space16),
          Text(l.aboutSources, style: text.titleMedium),
          const SizedBox(height: Tokens.space8),
          Text(l.ruleDemoKey, style: text.bodyMedium),
          const RuleSourceLabel(entry: _demoEntry),
        ],
      ),
    );
  }
}
