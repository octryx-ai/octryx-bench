import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/onboarding_tokens.dart';
import '../../../core/theme/tokens.dart';

/// Header band of an onboarding page: a 135-degree gradient with a centred
/// icon in a surface circle. Dark theme lowers both stops by 12 lightness
/// points.
class OnboardingHeader extends StatelessWidget {
  /// Creates the header with [icon] and the gradient [hue].
  const OnboardingHeader({
    required this.icon,
    this.hue = OnboardingTokens.hue,
    super.key,
  });

  /// Icon shown in the centre.
  final IconData icon;

  /// Hue of the gradient in HSL degrees.
  final double hue;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final delta = c.isDark ? OnboardingTokens.darkLightnessDelta : 0.0;
    final start = HSLColor.fromAHSL(
      1,
      hue,
      OnboardingTokens.saturation,
      OnboardingTokens.lightStart - delta,
    ).toColor();
    final end = HSLColor.fromAHSL(
      1,
      (hue + OnboardingTokens.hueOffset) % Tokens.fullTurnDegrees,
      OnboardingTokens.saturation,
      OnboardingTokens.lightEnd - delta,
    ).toColor();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(Tokens.radiusCard),
        ),
      ),
      child: SizedBox(
        height: OnboardingTokens.headerHeight,
        child: Center(
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface.withValues(
                  alpha: OnboardingTokens.circleAlpha,
                ),
              ),
              child: SizedBox(
                width: OnboardingTokens.iconCircle,
                height: OnboardingTokens.iconCircle,
                child: Icon(icon, size: Tokens.iconSize64, color: c.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
