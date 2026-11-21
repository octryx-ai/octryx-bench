import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'banner_severity.dart';

/// Banner with icon, text and an optional action.
class AppBanner extends StatelessWidget {
  /// Creates a banner.
  const AppBanner({
    required this.severity,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Severity, drives icon and colour.
  final BannerSeverity severity;

  /// Banner text.
  final String message;

  /// Optional action label.
  final String? actionLabel;

  /// Action callback.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final (icon, color) = switch (severity) {
      BannerSeverity.info => (Icons.info_outline, c.accent),
      BannerSeverity.warning => (Icons.warning_amber, c.warning),
      BannerSeverity.error => (Icons.error_outline, c.error),
    };
    final label = actionLabel;
    return Semantics(
      container: true,
      liveRegion: severity != BannerSeverity.info,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceVariant,
          borderRadius: BorderRadius.circular(Tokens.radiusField),
          border: Border.all(color: color, width: Tokens.borderWidth),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Tokens.space12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: Tokens.space12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (label != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: color,
                    minimumSize: const Size(
                      Tokens.touchTarget,
                      Tokens.touchTarget,
                    ),
                  ),
                  child: Text(label),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
