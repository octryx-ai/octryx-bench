import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/link_card.dart';
import '../../../core/widgets/page_body.dart';

/// Mehr: menu to Wasser, Pflege, Einstellungen and the style guide.
class MoreScreen extends StatelessWidget {
  /// Creates the screen.
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      section: AppSection.more,
      title: l.more,
      body: PageBody(
        children: [
          LinkCard(
            label: l.water,
            icon: AppSection.water.icon,
            route: AppRoutes.water,
          ),
          LinkCard(
            label: l.care,
            icon: AppSection.care.icon,
            route: AppRoutes.care,
          ),
          LinkCard(
            label: l.settings,
            icon: AppSection.settings.icon,
            route: AppRoutes.settings,
          ),
          LinkCard(
            label: l.styleGuide,
            icon: Icons.palette,
            route: AppRoutes.styleGuide,
          ),
        ],
      ),
    );
  }
}
