import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import 'grinder_card.dart';

/// Tab Mühlen: grinder cards or the empty state.
class GrinderList extends StatelessWidget {
  /// Creates the tab content.
  const GrinderList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = AppScope.of(context);
    final grinders = data.grinders;
    if (grinders.isEmpty) {
      return EmptyState(
        icon: Icons.adjust,
        title: l.grindersEmptyTitle,
        body: l.grindersEmptyBody,
        actionLabel: l.grinderAdd,
        onAction: () => Navigator.of(context).pushNamed(AppRoutes.grinderNew),
      );
    }
    return PageBody(
      children: [
        for (final g in grinders)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.space12),
            child: GrinderCard(
              grinder: g,
              onDelete: () => data.deleteGrinder(g.id),
            ),
          ),
      ],
    );
  }
}
