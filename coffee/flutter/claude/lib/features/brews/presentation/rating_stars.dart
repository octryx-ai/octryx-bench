import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';

/// Rating input of one to five stars; tapping the chosen star again clears
/// the rating.
class RatingStars extends StatelessWidget {
  /// Creates the input.
  const RatingStars({required this.rating, required this.onChanged, super.key});

  /// Current rating, or null.
  final int? rating;

  /// Called with the new rating, or null when cleared.
  final ValueChanged<int?> onChanged;

  /// Highest rating.
  static const int max = 5;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.brewRating, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: Tokens.space4),
        Row(
          children: [
            for (var i = 1; i <= max; i++)
              IconButton(
                key: Key('rating-$i'),
                tooltip: l.ratingStars(i),
                constraints: const BoxConstraints(
                  minWidth: Tokens.touchTarget,
                  minHeight: Tokens.touchTarget,
                ),
                icon: Semantics(
                  label: l.ratingStars(i),
                  selected: i == rating,
                  child: Icon(
                    i <= (rating ?? 0) ? Icons.star : Icons.star_border,
                    color: c.accent,
                  ),
                ),
                onPressed: () => onChanged(i == rating ? null : i),
              ),
          ],
        ),
      ],
    );
  }
}
