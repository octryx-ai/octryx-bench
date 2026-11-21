import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/rules/rule_entry.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/link_card.dart';
import '../../../core/widgets/page_body.dart';
import '../../../core/widgets/rule_source_label.dart';

/// Einstellungen; unit, export and import follow in a later story.
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  static const _demoEntry = RuleEntry(
    key: 'demo',
    value: 0,
    source: 'none',
    retrieved: '2026-11-16',
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return AppShell(
      section: AppSection.settings,
      title: l.settings,
      body: PageBody(
        children: [
          ComingSoon(title: l.settings),
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
