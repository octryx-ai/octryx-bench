import 'package:material_ui/material_ui.dart';

import '../l10n_context.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'app_button.dart';

/// Error message with a "Try again" action, used inside an error card.
class ErrorCardBody extends StatelessWidget {
  /// Creates the body.
  const ErrorCardBody({
    required this.message,
    required this.onRetry,
    super.key,
  });

  /// Error text.
  final String message;

  /// Retry callback.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: c.error),
            const SizedBox(width: Tokens.space8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: Tokens.space12),
        AppButton(label: context.l10n.retry, onPressed: onRetry),
      ],
    );
  }
}
