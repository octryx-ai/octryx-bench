import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/delete_action.dart';
import '../../care/domain/care_task.dart';
import '../domain/machine.dart';
import 'machine_ring.dart';

/// List card of a machine: ring with the real backflush task, name,
/// temperature, pre-infusion and the backflush status ("Backflush: Due" or
/// "In N days").
class MachineCard extends StatelessWidget {
  /// Creates the card; [onDelete] soft-deletes the machine.
  const MachineCard({
    required this.machine,
    required this.onDelete,
    this.backflush,
    super.key,
  });

  /// Machine shown.
  final Machine machine;

  /// Called by the delete button.
  final VoidCallback onDelete;

  /// The machine's backflush task; null shows a full, green ring.
  final CareTask? backflush;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final task = backflush;
    final daysLeft = task?.daysLeft ?? Tokens.backflushIntervalDays;
    final color = MachineRing.colorFor(AppColors.of(context), daysLeft);
    final status = task == null
        ? null
        : task.due
        ? l.careBackflushDue
        : l.careInDays(daysLeft);
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
            MachineRing(daysLeft: daysLeft, fraction: task?.ringFraction ?? 1),
            const SizedBox(width: Tokens.space16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          machine.name,
                          style: text.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status != null)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: Tokens.space8),
                            child: Text(
                              status,
                              key: Key('machine-status-${machine.id}'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelMedium!.copyWith(color: color),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    settings,
                    style: text.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
