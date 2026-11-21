import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Semantic colours of one theme brightness, built from [Tokens].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates a colour set.
  const AppColors({
    required this.brightness,
    required this.accent,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.success,
    required this.warning,
    required this.error,
  });

  /// Light colour set.
  static const AppColors light = AppColors(
    brightness: Brightness.light,
    accent: Tokens.primary,
    surface: Tokens.lightSurface,
    surfaceVariant: Tokens.lightSurfaceVariant,
    onSurface: Tokens.lightOnSurface,
    success: Tokens.lightSuccess,
    warning: Tokens.lightWarning,
    error: Tokens.lightError,
  );

  /// Dark colour set.
  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    accent: Tokens.primaryOnDark,
    surface: Tokens.darkSurface,
    surfaceVariant: Tokens.darkSurfaceVariant,
    onSurface: Tokens.darkOnSurface,
    success: Tokens.darkSuccess,
    warning: Tokens.darkWarning,
    error: Tokens.darkError,
  );

  /// Reads the colours of the current theme.
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  /// Brightness of this set.
  final Brightness brightness;

  /// Accent for text, icons and focus ring (primary; lighter copper in dark).
  final Color accent;

  /// Page background.
  final Color surface;

  /// Card and sidebar fill.
  final Color surfaceVariant;

  /// Text colour.
  final Color onSurface;

  /// Success colour.
  final Color success;

  /// Warning colour.
  final Color warning;

  /// Error colour.
  final Color error;

  /// Whether this is the dark set.
  bool get isDark => brightness == Brightness.dark;

  /// Card border: onSurface at 12 % alpha.
  Color get border => onSurface.withValues(alpha: Tokens.borderAlpha);

  /// Card shadow colour; none in dark (a border is used instead).
  Color? get shadow =>
      isDark ? null : onSurface.withValues(alpha: Tokens.shadowAlpha);

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) =>
      t < 0.5 || other is! AppColors ? this : other;
}
