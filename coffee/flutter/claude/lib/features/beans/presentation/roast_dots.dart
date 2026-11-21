import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../domain/roast_level.dart';

/// Four small dots, as many filled as the roast level has (light 1 to dark 4).
class RoastDots extends StatelessWidget {
  /// Creates the dots for [level].
  const RoastDots({required this.level, super.key});

  /// Number of dots drawn in total.
  static const int total = 4;

  /// Roast level to show.
  final RoastLevel level;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.of(context).surface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: Tokens.roastDotGap),
          SizedBox.square(
            dimension: Tokens.roastDotSize,
            child: DecoratedBox(
              key: Key(i < level.dots ? 'roast-dot-filled' : 'roast-dot-empty'),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < level.dots
                    ? surface
                    : surface.withValues(alpha: Tokens.roastDotEmptyAlpha),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
