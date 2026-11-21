import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/bean.dart';
import '../domain/pack.dart';
import 'bean_format.dart';
import 'bean_readiness_chip.dart';

/// One pack on the bean detail: roast date, size and remaining grams,
/// readiness chip, opened date or the Open button, plus edit and delete.
class PackRow extends StatelessWidget {
  /// Creates the row for [pack] of [bean].
  const PackRow({required this.bean, required this.pack, super.key});

  /// Bean the pack belongs to.
  final Bean bean;

  /// Pack shown.
  final Pack pack;

  Widget _icon(
    BuildContext context, {
    required String id,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) => IconButton(
    key: Key('$id-${pack.id}'),
    tooltip: label,
    constraints: const BoxConstraints(
      minWidth: Tokens.touchTarget,
      minHeight: Tokens.touchTarget,
    ),
    icon: Semantics(
      label: label,
      child: Icon(icon, color: color ?? AppColors.of(context).onSurface),
    ),
    onPressed: onPressed,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final data = AppScope.of(context);
    final format = AppFormat.of(context);
    final date = format.date(pack.roastDate);
    final opened = pack.openedAt;
    return AppCard(
      key: Key('pack-${pack.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.roastedOn(date), style: text.titleMedium)),
              _icon(
                context,
                id: 'pack-edit',
                icon: Icons.edit,
                label: l.editPack,
                onPressed: () =>
                    Navigator.of(context)
                        .pushNamed(AppRoutes.packEdit, arguments: pack.id),
              ),
              _icon(
                context,
                id: 'pack-delete',
                icon: Icons.delete_outline,
                label: l.deletePackNamed(date),
                color: c.error,
                onPressed: () => data.deletePack(pack.id),
              ),
            ],
          ),
          Text(
            l.packSizes(
              BeanFormat.grams(l, pack.remainingG),
              BeanFormat.grams(l, pack.sizeG),
            ),
            style: text.bodyMedium,
          ),
          const SizedBox(height: Tokens.space8),
          Wrap(
            spacing: Tokens.space12,
            runSpacing: Tokens.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BeanReadinessChip(
                readiness: data.rest.readiness(pack, bean, data.today),
              ),
              if (opened != null)
                Text(
                  l.openedOn(format.date(opened.toLocal())),
                  key: Key('pack-opened-${pack.id}'),
                  style: text.bodyMedium,
                )
              else
                OutlinedButton(
                  key: Key('pack-open-${pack.id}'),
                  onPressed: () => data.openPack(pack.id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(
                      Tokens.touchTarget,
                      Tokens.touchTarget,
                    ),
                    foregroundColor: c.accent,
                    side: BorderSide(color: c.accent),
                  ),
                  child: Text(l.openPack),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
