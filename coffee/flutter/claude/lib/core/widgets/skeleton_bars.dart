import 'package:material_ui/material_ui.dart';

import '../l10n_context.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Skeleton lines shown while a card is loading.
class SkeletonBars extends StatelessWidget {
  /// Creates the skeleton.
  const SkeletonBars({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget bar(double factor) => FractionallySizedBox(
      widthFactor: factor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.onSurface.withValues(alpha: Tokens.borderAlpha),
          borderRadius: BorderRadius.circular(Tokens.radiusField),
        ),
        child: const SizedBox(height: Tokens.skeletonHeight),
      ),
    );
    return Semantics(
      label: context.l10n.loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(0.6),
          const SizedBox(height: Tokens.space12),
          bar(1),
          const SizedBox(height: Tokens.space8),
          bar(0.8),
        ],
      ),
    );
  }
}
