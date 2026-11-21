import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/rules/rule_entry.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/app_choice_chips.dart';
import '../../../../core/widgets/rule_source_label.dart';
import '../../domain/brew_method.dart';
import '../../domain/filter_recipe_calculator.dart';
import '../brew_format.dart';

/// Filter method chips. Methods that borrow the V60 scheme say so and show
/// where that default comes from.
class FilterMethodField extends StatelessWidget {
  /// Creates the field.
  const FilterMethodField({
    required this.calculator,
    required this.method,
    required this.onChanged,
    super.key,
  });

  /// Tells which scheme and source a method uses.
  final FilterRecipeCalculator calculator;

  /// Chosen method.
  final BrewMethod method;

  /// Called with the tapped method.
  final ValueChanged<BrewMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final borrowed = calculator.schemeOf(method) != method;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.brewMethod, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: Tokens.space4),
        AppChoiceChips<BrewMethod>(
          keyPrefix: 'method',
          labels: {
            for (final m in BrewMethod.values)
              if (m.isFilter) m: BrewFormat.method(l, m),
          },
          selected: method,
          onSelected: onChanged,
        ),
        if (borrowed) ...[
          const SizedBox(height: Tokens.space8),
          Text(
            l.filterMethodNote,
            key: const Key('filter-method-note'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          RuleSourceLabel(
            key: const Key('filter-method-source'),
            entry: RuleEntry(
              key: '',
              value: null,
              source: calculator.sourceOf(method),
              retrieved: '',
            ),
          ),
        ],
      ],
    );
  }
}
