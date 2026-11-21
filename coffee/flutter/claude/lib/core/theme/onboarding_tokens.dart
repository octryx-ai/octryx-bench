/// Design tokens of the onboarding (SPEC-UI.md, LF13).
///
/// Like `Tokens`, this file may contain size and alpha literals; colours are
/// built at runtime from the hue, saturation and lightness values below.
abstract final class OnboardingTokens {
  /// Height of the header band (dp).
  static const double headerHeight = 160;

  /// Maximum width of the centred column (dp).
  static const double maxWidth = 480;

  /// Diameter of the surface circle behind the header icon (dp).
  static const double iconCircle = 96;

  /// Alpha of the surface circle behind the header icon.
  static const double circleAlpha = 0.9;

  /// Hue of the header gradient on page 1 (HSL degrees).
  static const double hue = 30;

  /// Hue offset of the second gradient stop (340 degrees, i.e. -20).
  static const double hueOffset = 340;

  /// Saturation of both gradient stops.
  static const double saturation = 0.55;

  /// Lightness of the first gradient stop (light theme).
  static const double lightStart = 0.62;

  /// Lightness of the second gradient stop (light theme).
  static const double lightEnd = 0.42;

  /// Lightness reduction of both gradient stops in the dark theme.
  static const double darkLightnessDelta = 0.12;

  /// Diameter of a progress dot (dp).
  static const double dotSize = 8;

  /// Gap between two progress dots (dp).
  static const double dotGap = 8;
}
