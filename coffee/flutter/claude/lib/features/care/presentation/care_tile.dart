import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';

/// Heute tile "Care" that shows how many tasks are due and opens `/care`.
class CareTile extends StatelessWidget {
  /// Creates the tile.
  const CareTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final due = AppScope.of(context).careTasks.where((t) => t.due).length;
    final summary = due == 0 ? l.careTileNone : l.careTileDue(due);
    return AppCard(
      key: const Key('link-${AppRoutes.care}'),
      semanticLabel: '${l.care}: $summary',
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.care),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Tokens.touchTarget),
        child: Row(
          children: [
            Icon(Icons.cleaning_services, color: c.accent),
            const SizedBox(width: Tokens.space16),
            Expanded(child: Text(l.care, style: text.titleMedium)),
            Text(
              summary,
              key: const Key('care-tile-summary'),
              style: text.labelLarge!.copyWith(
                color: due == 0 ? c.success : c.error,
              ),
            ),
            const SizedBox(width: Tokens.space8),
            Icon(Icons.chevron_right, color: c.onSurface),
          ],
        ),
      ),
    );
  }
}
