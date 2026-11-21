import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../inventory/presentation/stock_bar.dart';
import '../domain/bean_summary.dart';
import 'bean_format.dart';
import 'bean_image.dart';
import 'bean_readiness_chip.dart';

/// List card of a bean: gradient image, name, roaster, readiness chip,
/// remaining grams and the stock bar. Tap opens the detail.
class BeanCard extends StatelessWidget {
  /// Creates the card.
  const BeanCard({required this.summary, super.key});

  /// Bean with its packs and readiness.
  final BeanSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final bean = summary.bean;
    final stock = AppScope.of(context).stockStatus(bean.id);
    final readiness = summary.bestReadiness;
    return SizedBox(
      height: Tokens.listCardHeight,
      child: AppCard(
        key: Key('bean-${bean.id}'),
        semanticLabel: bean.name,
        padding: const EdgeInsets.symmetric(
          horizontal: Tokens.space12,
          vertical: Tokens.space4,
        ),
        onTap: () =>
            Navigator.of(context)
                .pushNamed(AppRoutes.beanDetail, arguments: bean.id),
        child: Row(
          children: [
            BeanImage(name: bean.name, roastLevel: bean.roastLevel),
            const SizedBox(width: Tokens.space12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bean.name,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    bean.roaster,
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: readiness == null
                              ? Text(l.noPack, style: text.bodySmall)
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: BeanReadinessChip(
                                    readiness: readiness,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: Tokens.space8),
                      Text(
                        BeanFormat.grams(l, summary.totalRemainingG),
                        key: Key('bean-grams-${bean.id}'),
                        style: text.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: Tokens.space4),
                  StockBar(
                    stockG: stock.totalStockG,
                    orderPoint: stock.orderPoint,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
