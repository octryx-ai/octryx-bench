import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/onboarding_tokens.dart';
import '../../../core/theme/tokens.dart';

/// Progress of the onboarding: one dot per page, the reached pages filled in
/// primary, followed by the text "k von 4" / "k of 4".
class OnboardingProgress extends StatelessWidget {
  /// Creates the indicator for page [step] (1-based) of [total] pages.
  const OnboardingProgress({
    required this.step,
    required this.total,
    super.key,
  });

  /// Current page, 1-based.
  final int step;

  /// Number of pages.
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final dot = OnboardingTokens.dotSize;
    return Semantics(
      label: l.onboardingProgressSemantics(step, total),
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: OnboardingTokens.dotGap),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= step
                    ? primary
                    : c.onSurface.withValues(alpha: Tokens.trackAlpha),
              ),
              child: SizedBox(width: dot, height: dot),
            ),
          ],
          const SizedBox(width: Tokens.space12),
          Text(
            l.onboardingProgress(step, total),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
