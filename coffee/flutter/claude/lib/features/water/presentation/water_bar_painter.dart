import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';

/// Paints a measurement bar: track, marked target range, value fill.
class WaterBarPainter extends CustomPainter {
  /// Creates the painter; all positions are fractions (0 to 1) of the width.
  const WaterBarPainter({
    required this.valueFraction,
    required this.rangeStart,
    required this.rangeEnd,
    required this.fillColor,
    required this.trackColor,
    required this.bandColor,
    required this.markColor,
  });

  /// Filled share; 0 for an unmeasured parameter.
  final double valueFraction;

  /// Start of the target range, or null for an open lower bound.
  final double? rangeStart;

  /// End of the target range, or null for an open upper bound.
  final double? rangeEnd;

  /// Colour of the value fill (error outside, success inside).
  final Color fillColor;

  /// Colour of the full track.
  final Color trackColor;

  /// Tint of the target range.
  final Color bandColor;

  /// Colour of the range end markers.
  final Color markColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(Tokens.barRadius);
    final track = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(track, Paint()..color = trackColor);
    canvas.save();
    canvas.clipRRect(track);
    final from = (rangeStart ?? 0) * size.width;
    final to = (rangeEnd ?? 1) * size.width;
    if (to > from) {
      canvas.drawRect(
        Rect.fromLTRB(from, 0, to, size.height),
        Paint()..color = bandColor,
      );
    }
    final value = valueFraction.clamp(0.0, 1.0) * size.width;
    if (value > 0) {
      canvas.drawRect(
        Rect.fromLTRB(0, 0, value, size.height),
        Paint()..color = fillColor,
      );
    }
    canvas.restore();
    final mark = Paint()
      ..color = markColor
      ..strokeWidth = Tokens.barMarkWidth;
    for (final x in [rangeStart, rangeEnd]) {
      if (x == null) continue;
      final dx = x * size.width;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), mark);
    }
  }

  @override
  bool shouldRepaint(WaterBarPainter old) =>
      old.valueFraction != valueFraction ||
      old.rangeStart != rangeStart ||
      old.rangeEnd != rangeEnd ||
      old.fillColor != fillColor ||
      old.trackColor != trackColor ||
      old.bandColor != bandColor ||
      old.markColor != markColor;
}
