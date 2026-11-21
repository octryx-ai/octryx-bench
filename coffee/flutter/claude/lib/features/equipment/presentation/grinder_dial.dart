import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/arc_painter.dart';
import '../domain/grinder.dart';

/// 56 dp visual of a grinder card: 270 degree arc, knob icon and the scale
/// minimum and maximum under the arc ends.
///
/// No grind setting exists yet, so [fraction] defaults to 0 and the arc
/// shows the track only; later stories pass the last used setting.
class GrinderDial extends StatelessWidget {
  /// Creates the dial for [grinder].
  const GrinderDial({required this.grinder, this.fraction = 0, super.key});

  /// Grinder whose scale is shown.
  final Grinder grinder;

  /// Share of the scale (setting - min) / (max - min), 0 to 1.
  final double fraction;

  static const _labelWidth = Tokens.touchTarget / 2;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final style = Theme.of(context).textTheme.labelSmall!;
    const size = Tokens.listVisualSize;
    final startRad = Tokens.arcStartDegrees * math.pi / Tokens.halfTurnDegrees;
    const radius = size / 2 - Tokens.arcStroke / 2;
    final dx = math.cos(startRad) * radius;
    final dy = math.sin(startRad) * radius;
    Widget label(String text, double centerX) => Positioned(
      left: centerX - _labelWidth / 2,
      top: size / 2 + dy,
      width: _labelWidth,
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size.square(size),
            painter: ArcPainter(
              fraction: fraction,
              trackColor: c.onSurface.withValues(alpha: Tokens.trackAlpha),
              valueColor: c.accent,
              startDegrees: Tokens.arcStartDegrees,
              sweepDegrees: Tokens.arcSweepDegrees,
            ),
          ),
          Center(
            child: Icon(
              Icons.adjust,
              size: Tokens.knobIconSize,
              color: c.accent,
            ),
          ),
          label(AppFormat.plain(grinder.scaleMin), size / 2 + dx),
          label(AppFormat.plain(grinder.scaleMax), size / 2 - dx),
        ],
      ),
    );
  }
}
