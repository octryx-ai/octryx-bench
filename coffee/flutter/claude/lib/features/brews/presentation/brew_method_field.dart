import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_choice_chips.dart';
import '../domain/brew_method.dart';
import 'brew_form_slot.dart';

/// Brew method choice; only espresso is available in this release.
class BrewMethodField extends StatelessWidget {
  /// Creates the field.
  const BrewMethodField({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BrewFormSlot(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.brewMethod, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: Tokens.space4),
          AppChoiceChips<BrewMethod>(
            keyPrefix: 'method',
            labels: {BrewMethod.espresso: l.methodEspresso},
            selected: BrewMethod.espresso,
            onSelected: (_) {},
          ),
        ],
      ),
    );
  }
}
