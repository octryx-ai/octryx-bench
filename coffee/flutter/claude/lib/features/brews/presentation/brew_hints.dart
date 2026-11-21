import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/banner_severity.dart';
import '../../beans/presentation/bean_format.dart';
import '../domain/purge_advice.dart';

/// Banners on top of the brew form: the blocking "add a grinder / machine /
/// pack first" hints and the R7 purge hint.
class BrewHints extends StatelessWidget {
  /// Creates the hints.
  const BrewHints({
    required this.noGrinder,
    required this.noMachine,
    required this.noPack,
    required this.advice,
    super.key,
  });

  /// No live grinder exists.
  final bool noGrinder;

  /// No live machine exists.
  final bool noMachine;

  /// No live pack exists.
  final bool noPack;

  /// Purge advice for the chosen grinder and bean, or null.
  final PurgeAdvice? advice;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final navigator = Navigator.of(context);
    final purge = advice;
    final banners = <Widget>[
      if (noGrinder)
        AppBanner(
          key: const Key('hint-no-grinder'),
          severity: BannerSeverity.warning,
          message: l.needGrinder,
          actionLabel: l.grinderAdd,
          onAction: () => navigator.pushNamed(AppRoutes.grinderNew),
        ),
      if (noMachine)
        AppBanner(
          key: const Key('hint-no-machine'),
          severity: BannerSeverity.warning,
          message: l.needMachine,
          actionLabel: l.machineAdd,
          onAction: () => navigator.pushNamed(AppRoutes.machineNew),
        ),
      if (noPack)
        AppBanner(
          key: const Key('hint-no-pack'),
          severity: BannerSeverity.warning,
          message: l.needPack,
        ),
      if (purge != null)
        AppBanner(
          key: const Key('hint-purge'),
          severity: BannerSeverity.info,
          message: switch (purge.reason) {
            PurgeReason.beanChange => l.purgeBeanChange(
              BeanFormat.grams(l, purge.purgeG),
            ),
            PurgeReason.idle => l.purgeIdle(BeanFormat.grams(l, purge.purgeG)),
          },
        ),
    ];
    return Column(
      children: [
        for (final b in banners)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.space16),
            child: b,
          ),
      ],
    );
  }
}
