import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/add_action.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import 'water_card.dart';

/// Wasser: list of water profiles, or the empty state.
class WaterScreen extends StatelessWidget {
  /// Creates the screen.
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final profiles = AppScope.of(context).waterProfiles;
    return AppShell(
      section: AppSection.water,
      title: l.water,
      actions: [AddAction(route: AppRoutes.waterNew, label: l.waterAdd)],
      body: profiles.isEmpty
          ? EmptyState(
              icon: Icons.water_drop,
              title: l.waterEmptyTitle,
              body: l.waterEmptyBody,
              actionLabel: l.waterAdd,
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.waterNew),
            )
          : PageBody(
              children: [
                for (final p in profiles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Tokens.space12),
                    child: WaterCard(profile: p),
                  ),
              ],
            ),
    );
  }
}
