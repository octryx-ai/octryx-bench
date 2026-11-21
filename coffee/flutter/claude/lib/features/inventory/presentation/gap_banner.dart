import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/banner_severity.dart';
import '../domain/gap_action.dart';
import '../domain/gap_warning.dart';

/// Banner "No ready coffee from ... to ..." with its action (SPEC R6, LF6):
/// "Open pack {x}" opens the pack, "Order now" is a plain label.
class GapBanner extends StatelessWidget {
  /// Creates the banner for [gap]; [beanName] is shown as second line.
  const GapBanner({required this.gap, this.beanName, super.key});

  /// The gap to announce.
  final GapWarning gap;

  /// Bean name for the second line, or null on the bean detail.
  final String? beanName;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final format = AppFormat.of(context);
    final pack = gap.pack;
    final opens = gap.action == GapAction.openPack && pack != null;
    return KeyedSubtree(
      key: const Key('gap-banner'),
      child: AppBanner(
        severity: gap.readyStockG <= 0
            ? BannerSeverity.error
            : BannerSeverity.warning,
        message: l.gapBanner(format.date(gap.from), format.date(gap.to)),
        detail: beanName,
        actionLabel: opens
            ? l.gapOpenPack(format.date(pack.roastDate))
            : l.stockOrderNow,
        onAction: opens ? () => AppScope.of(context).openPack(pack.id) : null,
      ),
    );
  }
}
