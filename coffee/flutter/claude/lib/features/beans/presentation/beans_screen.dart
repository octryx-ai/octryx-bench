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
import 'bean_card.dart';

/// Bohnen: list of beans sorted by earliest ready date, or the empty state.
class BeansScreen extends StatelessWidget {
  /// Creates the screen.
  const BeansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final summaries = AppScope.of(context).beanSummaries;
    return AppShell(
      section: AppSection.beans,
      title: l.beans,
      actions: [AddAction(route: AppRoutes.beanNew, label: l.addBean)],
      body: summaries.isEmpty
          ? EmptyState(
              icon: Icons.coffee,
              title: l.beansEmptyTitle,
              body: l.emptyBody,
              actionLabel: l.addBean,
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.beanNew),
            )
          : PageBody(
              children: [
                for (final s in summaries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Tokens.space12),
                    child: BeanCard(summary: s),
                  ),
              ],
            ),
    );
  }
}
