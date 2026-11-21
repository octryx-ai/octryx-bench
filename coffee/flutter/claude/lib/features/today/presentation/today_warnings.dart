import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/banner_severity.dart';
import '../../care/presentation/care_format.dart';
import '../../inventory/presentation/gap_banner.dart';
import '../../inventory/presentation/order_banner.dart';
import '../domain/app_warning.dart';
import '../domain/warning_kind.dart';
import '../domain/warning_severity.dart';

/// Region 1 of Heute: one banner per warning (gap, order, care due, water).
class TodayWarnings extends StatelessWidget {
  /// Creates the region for [warnings].
  const TodayWarnings({required this.warnings, super.key});

  /// Warnings to show, in display order.
  final List<AppWarning> warnings;

  Widget _banner(BuildContext context, AppWarning w) {
    final l = context.l10n;
    final navigator = Navigator.of(context);
    final severity = w.severity == WarningSeverity.error
        ? BannerSeverity.error
        : BannerSeverity.warning;
    final bean = w.bean;
    final care = w.care;
    final water = w.water;
    switch (w.kind) {
      case WarningKind.gap:
        return GapBanner(gap: w.gap!, beanName: bean?.name);
      case WarningKind.order:
        return OrderBanner(
          stock: w.stock!,
          beanName: bean?.name,
          onOpen: bean == null
              ? null
              : () => navigator.pushNamed(
                  AppRoutes.beanDetail,
                  arguments: bean.id,
                ),
        );
      case WarningKind.careDue:
        return AppBanner(
          severity: severity,
          message: l.warningCareDue(CareFormat.title(l, care!)),
          actionLabel: l.warningCareAction,
          onAction: () => navigator.pushNamed(AppRoutes.care),
        );
      case WarningKind.water:
        return AppBanner(
          severity: severity,
          message: l.warningWater(water!.name),
          actionLabel: l.warningWaterAction,
          onAction: () =>
              navigator.pushNamed(AppRoutes.waterDetail, arguments: water.id),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('today-warnings'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final w in warnings)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.space12),
            child: _banner(context, w),
          ),
      ],
    );
  }
}
