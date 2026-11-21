import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_text_theme.dart';
import 'tokens.dart';

/// Builds the light and dark [ThemeData] from the design tokens.
abstract final class AppTheme {
  /// Light theme.
  static ThemeData light() => _build(AppColors.light);

  /// Dark theme.
  static ThemeData dark() => _build(AppColors.dark);

  static ThemeData _build(AppColors c) {
    final scheme = ColorScheme(
      brightness: c.brightness,
      primary: c.isDark ? c.accent : Tokens.primary,
      onPrimary: c.isDark ? c.surface : Tokens.onPrimary,
      secondary: c.accent,
      onSecondary: c.surface,
      error: c.error,
      onError: c.surface,
      surface: c.surface,
      onSurface: c.onSurface,
      surfaceContainerHighest: c.surfaceVariant,
      outline: c.border,
    );
    final text = AppTextTheme.build(c.onSurface);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surface,
      canvasColor: c.surface,
      textTheme: text,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: text.labelLarge!.copyWith(color: scheme.onPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfaceVariant,
        indicatorColor: c.accent.withValues(alpha: Tokens.tintAlpha),
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium!.copyWith(color: c.onSurface),
        ),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: c.onSurface)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surfaceVariant,
        indicatorColor: c.accent.withValues(alpha: Tokens.tintAlpha),
        minWidth: Tokens.railMinWidth,
        selectedIconTheme: IconThemeData(color: c.accent),
        unselectedIconTheme: IconThemeData(color: c.onSurface),
        selectedLabelTextStyle: text.labelMedium!.copyWith(color: c.accent),
        unselectedLabelTextStyle: text.labelMedium!.copyWith(
          color: c.onSurface,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.accent,
        unselectedLabelColor: c.onSurface,
        indicatorColor: c.accent,
        dividerColor: c.border,
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: Tokens.borderWidth,
        space: Tokens.borderWidth,
      ),
    );
  }
}
