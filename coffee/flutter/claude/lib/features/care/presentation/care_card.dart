import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/care_status.dart';
import '../domain/care_task.dart';
import 'care_format.dart';

/// Card of one care task: title, status, shots since last time, last done
/// date and the primary "Done" button (SPEC "Pflege").
class CareCard extends StatelessWidget {
  /// Creates the card for [task].
  const CareCard({required this.task, super.key});

  /// Task shown.
  final CareTask task;

  String get _id => '${task.kind.code}-${task.machineId ?? task.grinderId}';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final color = switch (task.status) {
      CareStatus.due => c.error,
      CareStatus.soon => c.warning,
      CareStatus.ok => c.success,
    };
    return AppCard(
      key: Key('care-$_id'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(CareFormat.title(l, task), style: text.titleMedium),
              ),
              const SizedBox(width: Tokens.space8),
              Text(
                CareFormat.status(l, task),
                key: Key('care-status-$_id'),
                style: text.labelLarge!.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: Tokens.space8),
          if (CareFormat.showsShots(task))
            Text(l.careShotsSince(task.shotsSince), style: text.bodyMedium),
          Text(
            CareFormat.lastDone(l, AppFormat.of(context), task),
            style: text.bodyMedium,
          ),
          const SizedBox(height: Tokens.space12),
          Semantics(
            container: true,
            child: AppButton(
              key: Key('care-done-$_id'),
              label: l.careDone,
              onPressed: () => AppScope.of(context).markCareDone(task),
            ),
          ),
        ],
      ),
    );
  }
}
