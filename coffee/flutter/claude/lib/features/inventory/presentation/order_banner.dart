import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/banner_severity.dart';
import '../domain/stock_status.dart';

/// "Order now" banner with the days of cover (SPEC R5, LF6). Shown on the
/// bean detail and, with [beanName], on Heute.
class OrderBanner extends StatelessWidget {
  /// Creates the banner for [stock]; [onOpen] adds an "open bean" action.
  const OrderBanner({
    required this.stock,
    this.beanName,
    this.onOpen,
    super.key,
  });

  /// Stock figures of the bean.
  final StockStatus stock;

  /// Bean name for the second line, or null on the detail itself.
  final String? beanName;

  /// Opens the bean; null hides the action.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cover = stock.daysOfCover;
    final name = beanName;
    final days = cover == null ? null : AppFormat.of(context).decimal(cover);
    final detail = switch ((name, days)) {
      (final String n, final String d) => l.todayBeanOrderDetail(n, d),
      (final String n, null) => n,
      (null, final String d) => l.stockDaysLeft(d),
      _ => null,
    };
    return KeyedSubtree(
      key: const Key('order-banner'),
      child: AppBanner(
        severity: stock.totalStockG <= 0
            ? BannerSeverity.error
            : BannerSeverity.warning,
        message: l.stockOrderNow,
        detail: detail,
        actionLabel: onOpen == null ? null : l.bannerAction,
        onAction: onOpen,
      ),
    );
  }
}
