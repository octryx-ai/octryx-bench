import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/delete_action.dart';
import '../../../core/widgets/page_body.dart';
import '../domain/bean_summaries.dart';
import 'bean_format.dart';
import 'bean_header.dart';
import 'bean_readiness_chip.dart';
import 'pack_row.dart';
import 'stat_tile.dart';

/// Detail of a bean: header band, key figures, pack list and "Add pack".
class BeanDetailScreen extends StatelessWidget {
  /// Creates the detail of the bean with [beanId].
  const BeanDetailScreen({required this.beanId, super.key});

  /// Id of the bean shown.
  final String? beanId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final data = AppScope.of(context);
    final id = beanId;
    final bean = id == null ? null : data.beanById(id);
    if (bean == null || bean.isDeleted) {
      return Scaffold(appBar: AppBar(title: Text(l.beanDetail)));
    }
    final summary = BeanSummaries.build(
      beans: [bean],
      packs: data.packsOf(bean.id),
      calc: data.rest,
      today: data.today,
    ).first;
    final ready = summary.earliestReadyDate;
    final best = summary.bestReadiness;
    return Scaffold(
      appBar: AppBar(
        title: Text(bean.name),
        actions: [
          IconButton(
            key: const Key('action-edit'),
            tooltip: l.edit,
            icon: Semantics(label: l.edit, child: const Icon(Icons.edit)),
            constraints: const BoxConstraints(
              minWidth: Tokens.touchTarget,
              minHeight: Tokens.touchTarget,
            ),
            onPressed: () =>
                Navigator.of(context)
                    .pushNamed(AppRoutes.beanEdit, arguments: bean.id),
          ),
          DeleteAction(
            name: bean.name,
            onDelete: () {
              final navigator = Navigator.of(context);
              data.deleteBean(bean.id);
              navigator.pop();
            },
          ),
        ],
      ),
      body: PageBody(
        children: [
          BeanHeader(bean: bean),
          const SizedBox(height: Tokens.space16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatTile(
                    key: const Key('tile-remaining'),
                    label: l.tileRemaining,
                    value: BeanFormat.grams(l, summary.totalRemainingG),
                  ),
                ),
                const SizedBox(width: Tokens.space12),
                Expanded(
                  child: StatTile(
                    key: const Key('tile-ready'),
                    label: l.tileReadyDate,
                    value: ready == null
                        ? '–'
                        : AppFormat.of(context).date(ready),
                    extra: best == null
                        ? null
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: BeanReadinessChip(readiness: best),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Tokens.space24),
          Text(l.packsTitle, style: text.titleLarge),
          const SizedBox(height: Tokens.space12),
          if (summary.packs.isEmpty)
            Text(l.noPacksYet, style: text.bodyMedium)
          else
            for (final p in summary.packs)
              Padding(
                padding: const EdgeInsets.only(bottom: Tokens.space12),
                child: PackRow(bean: bean, pack: p),
              ),
          const SizedBox(height: Tokens.space8),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              key: const Key('pack-add'),
              label: l.packForm,
              onPressed: () =>
                  Navigator.of(context)
                      .pushNamed(AppRoutes.packNew, arguments: bean.id),
            ),
          ),
        ],
      ),
    );
  }
}
