import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'app_button.dart';

/// Empty state: 64 dp icon, title, explanation and one action.
class EmptyState extends StatelessWidget {
  /// Creates an empty state.
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  /// Illustration icon.
  final IconData icon;

  /// Title (20 sp).
  final String title;

  /// Explanation (14 sp).
  final String body;

  /// Action button label.
  final String actionLabel;

  /// Action callback.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Tokens.iconSize64,
            color: AppColors.of(context).accent
                .withValues(alpha: Tokens.emptyIconAlpha),
          ),
          const SizedBox(height: Tokens.space16),
          Text(title, style: text.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: Tokens.space8),
          Text(body, style: text.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: Tokens.space16),
          AppButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}
