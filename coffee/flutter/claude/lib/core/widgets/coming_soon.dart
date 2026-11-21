import 'package:material_ui/material_ui.dart';

import '../l10n_context.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Notice for features that arrive in a later story.
class ComingSoon extends StatelessWidget {
  /// Creates the notice; [title] is the screen the notice stands in for.
  const ComingSoon({required this.title, super.key});

  /// Screen title.
  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    return Semantics(
      container: true,
      label: '$title: ${l.comingSoon}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Tokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: Tokens.iconSize64,
              color: AppColors.of(context).accent
                  .withValues(alpha: Tokens.emptyIconAlpha),
            ),
            const SizedBox(height: Tokens.space16),
            Text(
              title,
              style: text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Tokens.space8),
            Text(l.comingSoon, style: text.titleLarge),
            const SizedBox(height: Tokens.space8),
            Text(
              l.comingSoonBody,
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
