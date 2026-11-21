import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Text styles: headings in a serif, body in a sans family with fallbacks.
abstract final class AppTextTheme {
  /// Builds the text theme in [color].
  static TextTheme build(Color color) {
    TextStyle body(double size, {FontWeight? weight}) => TextStyle(
      fontFamily: Tokens.fontBody,
      fontFamilyFallback: Tokens.fontBodyFallback,
      fontSize: size,
      fontWeight: weight,
      height: Tokens.lineHeight,
      color: color,
    );
    TextStyle heading(double size) => TextStyle(
      fontFamily: Tokens.fontHeading,
      fontFamilyFallback: Tokens.fontHeadingFallback,
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
    );
    return TextTheme(
      displayLarge: heading(Tokens.fontSize72),
      displayMedium: heading(Tokens.fontSize48),
      displaySmall: heading(Tokens.fontSize32),
      headlineMedium: heading(Tokens.fontSize24),
      headlineSmall: heading(Tokens.fontSize20),
      titleLarge: heading(Tokens.fontSize20),
      titleMedium: body(Tokens.fontSize16, weight: FontWeight.w600),
      titleSmall: body(Tokens.fontSize14, weight: FontWeight.w600),
      bodyLarge: body(Tokens.fontSize16),
      bodyMedium: body(Tokens.fontSize14),
      bodySmall: body(Tokens.fontSize12),
      labelLarge: body(Tokens.fontSize14, weight: FontWeight.w600),
      labelMedium: body(Tokens.fontSize12, weight: FontWeight.w600),
      labelSmall: body(Tokens.fontSize12),
    );
  }
}
