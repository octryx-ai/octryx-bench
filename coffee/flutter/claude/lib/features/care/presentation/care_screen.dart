import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import 'care_card.dart';

/// Pflege: one card per machine and grinder task, most urgent first, or the
/// empty state.
class CareScreen extends StatelessWidget {
  /// Creates the screen.
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tasks = AppScope.of(context).careTasks;
    return AppShell(
      section: AppSection.care,
      title: l.care,
      body: tasks.isEmpty
          ? EmptyState(
              icon: Icons.cleaning_services,
              title: l.careEmptyTitle,
              body: l.careEmptyBody,
              actionLabel: l.machineAdd,
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.machineNew),
            )
          : PageBody(
              children: [
                Text(
                  l.careManualHint,
                  key: const Key('care-manual-hint'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Tokens.space12),
                for (final t in tasks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Tokens.space12),
                    child: CareCard(task: t),
                  ),
              ],
            ),
    );
  }
}
