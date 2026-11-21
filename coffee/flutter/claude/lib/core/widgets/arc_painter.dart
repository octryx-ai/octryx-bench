import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// Paints a track arc and a value arc on top, clockwise.
///
/// Angles are in degrees measured clockwise from 3 o'clock. A [fraction] of 0
/// shows the track only.
class ArcPainter extends CustomPainter {
  /// Creates the painter.
  const ArcPainter({
    required this.fraction,
    required this.trackColor,
    required this.valueColor,
    required this.startDegrees,
    required this.sweepDegrees,
  });

  /// Filled share of the sweep, 0 to 1.
  final double fraction;

  /// Colour of the full track.
  final Color trackColor;

  /// Colour of the value arc.
  final Color valueColor;

  /// Start angle in degrees.
  final double startDegrees;

  /// Total sweep in degrees.
  final double sweepDegrees;

  static double _rad(double degrees) =>
      degrees * math.pi / Tokens.halfTurnDegrees;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(Tokens.arcStroke / 2);
    Paint stroke(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = Tokens.arcStroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    final start = _rad(startDegrees);
    canvas.drawArc(inset, start, _rad(sweepDegrees), false, stroke(trackColor));
    final value = fraction.clamp(0.0, 1.0);
    if (value > 0) {
      canvas.drawArc(
        inset,
        start,
        _rad(sweepDegrees) * value,
        false,
        stroke(valueColor),
      );
    }
  }

  @override
  bool shouldRepaint(ArcPainter old) =>
      old.fraction != fraction ||
      old.trackColor != trackColor ||
      old.valueColor != valueColor ||
      old.startDegrees != startDegrees ||
      old.sweepDegrees != sweepDegrees;
}
