/// Design tokens of the guided filter focus mode (SPEC "Fokus-Modus").
///
/// Like `Tokens`, this file may contain size and duration literals.
abstract final class FocusTokens {
  /// Font size of the running timer digits (sp).
  static const double timerFontSize = 72;

  /// Font size of the target running total (sp).
  static const double targetFontSize = 48;

  /// Alpha of the primary-colour flash at a step end.
  static const double flashAlpha = 0.20;

  /// How long the flash stays visible.
  static const Duration flashDuration = Duration(milliseconds: 300);
}
