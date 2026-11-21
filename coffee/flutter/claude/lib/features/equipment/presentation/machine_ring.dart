import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/arc_painter.dart';

/// 56 dp ring with the portafilter icon; the fill is the remaining days until
/// the next backflush divided by the 7 day interval.
class MachineRing extends StatelessWidget {
  /// Creates the ring for [daysLeft] remaining days.
  const MachineRing({required this.daysLeft, super.key});

  /// Days until the backflush is due (may be zero or negative).
  final int daysLeft;

  /// Ring and text colour for [daysLeft]: more than 2 days success, 1 to 2
  /// warning, 0 or less error.
  static Color colorFor(AppColors c, int daysLeft) {
    if (daysLeft > Tokens.ringSuccessAboveDays) return c.success;
    return daysLeft >= 1 ? c.warning : c.error;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = colorFor(c, daysLeft);
    final fraction = (daysLeft / Tokens.backflushIntervalDays).clamp(0.0, 1.0);
    return SizedBox(
      width: Tokens.listVisualSize,
      height: Tokens.listVisualSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(Tokens.listVisualSize),
            painter: ArcPainter(
              fraction: fraction,
              trackColor: c.onSurface.withValues(alpha: Tokens.trackAlpha),
              valueColor: color,
              startDegrees: Tokens.ringStartDegrees,
              sweepDegrees: Tokens.fullTurnDegrees,
            ),
          ),
          Icon(Icons.coffee_maker, size: Tokens.iconSize24, color: c.onSurface),
        ],
      ),
    );
  }
}
