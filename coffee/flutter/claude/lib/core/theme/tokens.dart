import 'package:flutter/widgets.dart';

/// Design tokens of the "warm roastery" direction (SPEC section "UI und Design").
///
/// This is the only file that may contain colour, size, spacing, radius,
/// type-size, breakpoint and duration literals; everything else references it.
abstract final class Tokens {
  // Brand colours.
  /// Copper primary (main action, active navigation).
  static const Color primary = Color(0xFF8A4B2A);

  /// Primary hover state (black overlay 8 %).
  static const Color primaryHover = Color(0xFF7F4527);

  /// Primary pressed state (black overlay 16 %).
  static const Color primaryPressed = Color(0xFF743F23);

  /// Text and icon colour on [primary].
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Lighter copper used for accents (text, icons, focus ring) on dark surfaces.
  static const Color primaryOnDark = Color(0xFFE8AE88);

  // Light palette.
  /// Fully transparent.
  static const Color transparent = Color(0x00000000);

  /// Light page background.
  static const Color lightSurface = Color(0xFFFBF6EF);

  /// Light card and sidebar fill.
  static const Color lightSurfaceVariant = Color(0xFFF0E6D8);

  /// Light text colour.
  static const Color lightOnSurface = Color(0xFF2A1E17);

  /// Light success.
  static const Color lightSuccess = Color(0xFF36703F);

  /// Light warning.
  static const Color lightWarning = Color(0xFF8A5A00);

  /// Light error.
  static const Color lightError = Color(0xFFB3261E);

  // Dark palette.
  /// Dark page background.
  static const Color darkSurface = Color(0xFF1F1814);

  /// Dark card and sidebar fill.
  static const Color darkSurfaceVariant = Color(0xFF2B211B);

  /// Dark text colour.
  static const Color darkOnSurface = Color(0xFFF3E9DD);

  /// Dark success.
  static const Color darkSuccess = Color(0xFF7CC28E);

  /// Dark warning.
  static const Color darkWarning = Color(0xFFE0B050);

  /// Dark error.
  static const Color darkError = Color(0xFFF2B8B5);

  // Alphas.
  /// Card border alpha on [lightOnSurface] / [darkOnSurface].
  static const double borderAlpha = 0.12;

  /// Disabled content alpha.
  static const double disabledAlpha = 0.38;

  /// Disabled card alpha.
  static const double disabledCardAlpha = 0.6;

  /// Card shadow alpha.
  static const double shadowAlpha = 0.08;

  /// Empty-state icon alpha.
  static const double emptyIconAlpha = 0.4;

  /// Alpha of a tinted banner background.
  static const double tintAlpha = 0.12;

  /// Alpha of an arc or bar track on `onSurface`.
  static const double trackAlpha = 0.15;

  /// Alpha of the marked target range on a bar.
  static const double rangeBandAlpha = 0.3;

  // Spacing (dp).
  /// Spacing 4 dp.
  static const double space4 = 4;

  /// Spacing 8 dp.
  static const double space8 = 8;

  /// Spacing 12 dp.
  static const double space12 = 12;

  /// Spacing 16 dp.
  static const double space16 = 16;

  /// Spacing 24 dp.
  static const double space24 = 24;

  /// Spacing 32 dp.
  static const double space32 = 32;

  /// Spacing 48 dp.
  static const double space48 = 48;

  // Radii (dp).
  /// Card radius.
  static const double radiusCard = 16;

  /// Field radius.
  static const double radiusField = 12;

  /// Chip radius (pill).
  static const double radiusChip = 999;

  // Type scale (sp).
  /// 12 sp.
  static const double fontSize12 = 12;

  /// 14 sp.
  static const double fontSize14 = 14;

  /// 16 sp.
  static const double fontSize16 = 16;

  /// 20 sp.
  static const double fontSize20 = 20;

  /// 24 sp.
  static const double fontSize24 = 24;

  /// 32 sp.
  static const double fontSize32 = 32;

  /// 48 sp.
  static const double fontSize48 = 48;

  /// 72 sp.
  static const double fontSize72 = 72;

  // Fonts.
  /// Heading family (serif).
  static const String fontHeading = 'Fraunces';

  /// Heading fallbacks.
  static const List<String> fontHeadingFallback = ['Georgia', 'serif'];

  /// Body family (sans).
  static const String fontBody = 'Inter';

  /// Body fallbacks.
  static const List<String> fontBodyFallback = [
    'Roboto',
    'Helvetica',
    'Arial',
    'sans-serif',
  ];

  // Breakpoints (dp).
  /// Phone below this width.
  static const double breakpointTablet = 600;

  /// Desktop from this width.
  static const double breakpointDesktop = 1024;

  // Dimensions (dp).
  /// Minimum touch target.
  static const double touchTarget = 48;

  /// Desktop sidebar width.
  static const double sidebarWidth = 240;

  /// Maximum content width on wide screens.
  static const double contentMaxWidth = 720;

  /// Hairline border width.
  static const double borderWidth = 1;

  /// Selected card border width.
  static const double selectedBorderWidth = 2;

  /// Focus ring width.
  static const double focusRingWidth = 2;

  /// Gap between the focused element and its ring.
  static const double focusRingGap = 2;

  /// Spinner size inside buttons.
  static const double spinnerSize = 20;

  /// Spinner stroke width.
  static const double spinnerStroke = 2;

  /// Standard icon size.
  static const double iconSize24 = 24;

  /// Illustration icon size (empty states).
  static const double iconSize64 = 64;

  /// Card shadow vertical offset.
  static const double shadowOffset = 2;

  /// Card shadow vertical offset on hover.
  static const double shadowOffsetHover = 4;

  /// Card shadow blur.
  static const double shadowBlur = 8;

  /// Skeleton bar height.
  static const double skeletonHeight = 16;

  /// Swatch edge in the style guide.
  static const double swatchSize = 56;

  /// Narrow state tile width in the style guide.
  static const double stateTileWidth = 280;

  /// Minimum width of the tablet navigation rail.
  static const double railMinWidth = 80;

  /// Height of a list card (beans, grinders, machines, water).
  static const double listCardHeight = 88;

  /// Visual anchor edge on a list card.
  static const double listVisualSize = 56;

  /// Stroke of the grinder arc and the machine ring.
  static const double arcStroke = 4;

  /// Knob icon inside the grinder arc.
  static const double knobIconSize = 40;

  /// Start angle of the grinder arc in degrees (clockwise from 3 o'clock).
  static const double arcStartDegrees = 135;

  /// Sweep of the grinder arc in degrees.
  static const double arcSweepDegrees = 270;

  /// Start angle of the machine ring in degrees (12 o'clock).
  static const double ringStartDegrees = -90;

  /// Full turn in degrees.
  static const double fullTurnDegrees = 360;

  /// Half turn in degrees (radian conversion).
  static const double halfTurnDegrees = 180;

  /// Height of a measurement bar.
  static const double barHeight = 8;

  /// Corner radius of a measurement bar.
  static const double barRadius = 4;

  /// Width of the range markers on a bar.
  static const double barMarkWidth = 2;

  /// Width reserved for the parameter value next to its bar.
  static const double barValueWidth = 96;

  /// Days between two backflushes (full ring).
  static const int backflushIntervalDays = 7;

  /// Remaining days above which the ring is green.
  static const int ringSuccessAboveDays = 2;

  // Durations.
  /// Short UI transition.
  static const Duration fast = Duration(milliseconds: 150);

  // Line heights.
  /// Body line height factor.
  static const double lineHeight = 1.4;
}
