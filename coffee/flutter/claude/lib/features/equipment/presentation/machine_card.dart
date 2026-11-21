import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/delete_action.dart';
import '../domain/machine.dart';
import 'machine_ring.dart';

/// List card of a machine: ring with days to backflush, name, temperature and
/// pre-infusion.
///
/// Without a backflush event (care story) the ring is full: 7 days.
class MachineCard extends StatelessWidget {
  /// Creates the card; [onDelete] soft-deletes the machine.
  const MachineCard({
    required this.machine,
    required this.onDelete,
    this.daysLeft = Tokens.backflushIntervalDays,
    super.key,
  });

  /// Machine shown.
  final Machine machine;

  /// Called by the delete button.
  final VoidCallback onDelete;

  /// Days until the backflush is due.
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final color = MachineRing.colorFor(AppColors.of(context), daysLeft);
    final settings =
        '${l.celsiusValue(AppFormat.plain(machine.brewTempC))} · '
        '${l.secondsValue(AppFormat.plain(machine.preinfusionS))}';
    return SizedBox(
      height: Tokens.listCardHeight,
      child: AppCard(
        key: Key('machine-${machine.id}'),
        semanticLabel: machine.name,
        onTap: () =>
            Navigator.of(context)
                .pushNamed(AppRoutes.machineEdit, arguments: machine.id),
        child: Row(
          children: [
            MachineRing(daysLeft: daysLeft),
            const SizedBox(width: Tokens.space16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.name,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          settings,
                          style: text.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Tokens.space8),
                      Text(
                        l.daysCount(daysLeft),
                        style: text.labelMedium!.copyWith(color: color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DeleteAction(name: machine.name, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}
