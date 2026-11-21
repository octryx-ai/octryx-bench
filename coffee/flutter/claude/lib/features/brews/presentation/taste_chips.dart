import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_choice_chips.dart';
import '../domain/taste.dart';
import 'brew_format.dart';

/// Taste input: sour, bitter, weak or balanced; tapping the chosen chip again
/// clears the choice.
class TasteChips extends StatelessWidget {
  /// Creates the input.
  const TasteChips({required this.taste, required this.onChanged, super.key});

  /// Current taste, or null.
  final Taste? taste;

  /// Called with the new taste, or null when cleared.
  final ValueChanged<Taste?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.brewTaste, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: Tokens.space4),
        AppChoiceChips<Taste>(
          keyPrefix: 'taste',
          labels: {for (final t in Taste.values) t: BrewFormat.taste(l, t)},
          selected: taste,
          onSelected: (t) => onChanged(taste == t ? null : t),
        ),
      ],
    );
  }
}
