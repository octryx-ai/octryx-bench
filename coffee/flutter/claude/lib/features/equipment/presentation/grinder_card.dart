import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/delete_action.dart';
import '../domain/grinder.dart';
import 'grinder_dial.dart';

/// List card of a grinder: dial visual, name, dead space and scale.
class GrinderCard extends StatelessWidget {
  /// Creates the card; [onDelete] soft-deletes the grinder.
  const GrinderCard({required this.grinder, required this.onDelete, super.key});

  /// Grinder shown.
  final Grinder grinder;

  /// Called by the delete button.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final scale =
        '${AppFormat.plain(grinder.scaleMin)}–'
        '${AppFormat.plain(grinder.scaleMax)} · '
        '${AppFormat.plain(grinder.scaleStep)}';
    return SizedBox(
      height: Tokens.listCardHeight,
      child: AppCard(
        key: Key('grinder-${grinder.id}'),
        semanticLabel: grinder.name,
        onTap: () =>
            Navigator.of(context)
                .pushNamed(AppRoutes.grinderEdit, arguments: grinder.id),
        child: Row(
          children: [
            GrinderDial(grinder: grinder),
            const SizedBox(width: Tokens.space16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grinder.name,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        l.gramsValue(AppFormat.plain(grinder.deadSpaceG)),
                        style: text.bodyMedium,
                      ),
                      const SizedBox(width: Tokens.space8),
                      Flexible(
                        child: Text(
                          scale,
                          style: text.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DeleteAction(name: grinder.name, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}
