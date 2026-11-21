import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/banner_severity.dart';
import '../../../core/widgets/focus_ring.dart';

/// Bottom action bar of an onboarding page: the error banner after a failed
/// write, then a secondary row with Zurück (left) and Später (right) where they
/// exist, then the main row with Überspringen (left) and the primary button.
class OnboardingActions extends StatelessWidget {
  /// Creates the bar. While [saving], all actions are disabled.
  const OnboardingActions({
    required this.saving,
    required this.saveFailed,
    required this.onSkip,
    required this.onNext,
    this.onBack,
    this.onLater,
    this.nextLabel,
    super.key,
  });

  /// Whether the flag or a record is being written.
  final bool saving;

  /// Whether the last flag write failed; shows the error banner with a retry.
  final bool saveFailed;

  /// Skip callback, also used by the retry action.
  final VoidCallback onSkip;

  /// Zurück callback; null hides the button.
  final VoidCallback? onBack;

  /// Später callback; null hides the button.
  final VoidCallback? onLater;

  /// Primary callback; null disables the primary button.
  final VoidCallback? onNext;

  /// Label of the primary button; defaults to Weiter.
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Tokens.space24,
        Tokens.space12,
        Tokens.space24,
        Tokens.space16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (saveFailed) ...[
            AppBanner(
              severity: BannerSeverity.error,
              message: l.onboardingSaveFailed,
              actionLabel: l.onboardingRetry,
              onAction: saving ? null : onSkip,
            ),
            const SizedBox(height: Tokens.space12),
          ],
          if (onBack != null || onLater != null) ...[
            Row(
              children: [
                if (onBack != null)
                  OnboardingTextAction(
                    label: l.onboardingBack,
                    onPressed: saving ? null : onBack,
                  ),
                const Spacer(),
                if (onLater != null)
                  OnboardingTextAction(
                    label: l.onboardingLater,
                    onPressed: saving ? null : onLater,
                  ),
              ],
            ),
            const SizedBox(height: Tokens.space12),
          ],
          Row(
            children: [
              OnboardingTextAction(
                label: l.onboardingSkip,
                onPressed: saving ? null : onSkip,
              ),
              const Spacer(),
              AppButton(
                label: nextLabel ?? l.onboardingNext,
                onPressed: saving ? null : onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Text button with a 48 dp touch target and the 2 dp focus ring.
class OnboardingTextAction extends StatefulWidget {
  /// Creates the button; a null [onPressed] disables it.
  const OnboardingTextAction({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Button text.
  final String label;

  /// Tap callback; null means disabled.
  final VoidCallback? onPressed;

  @override
  State<OnboardingTextAction> createState() => _OnboardingTextActionState();
}

class _OnboardingTextActionState extends State<OnboardingTextAction> {
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: FocusRing(
        focused: _focus,
        radius: Tokens.radiusField,
        child: TextButton(
          onPressed: widget.onPressed,
          onFocusChange: (v) => setState(() => _focus = v),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.of(context).accent,
            minimumSize: const Size(Tokens.touchTarget, Tokens.touchTarget),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
