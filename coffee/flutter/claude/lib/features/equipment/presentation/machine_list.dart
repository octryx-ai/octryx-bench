import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import '../../care/domain/care_kind.dart';
import 'machine_card.dart';

/// Tab Maschinen: machine cards or the empty state.
class MachineList extends StatelessWidget {
  /// Creates the tab content.
  const MachineList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = AppScope.of(context);
    final machines = data.machines;
    final tasks = data.careTasks;
    if (machines.isEmpty) {
      return EmptyState(
        icon: Icons.coffee_maker,
        title: l.machinesEmptyTitle,
        body: l.machinesEmptyBody,
        actionLabel: l.machineAdd,
        onAction: () => Navigator.of(context).pushNamed(AppRoutes.machineNew),
      );
    }
    return PageBody(
      children: [
        for (final m in machines)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.space12),
            child: MachineCard(
              machine: m,
              backflush: tasks
                  .where(
                    (t) => t.kind == CareKind.backflush && t.machineId == m.id,
                  )
                  .firstOrNull,
              onDelete: () => data.deleteMachine(m.id),
            ),
          ),
      ],
    );
  }
}
