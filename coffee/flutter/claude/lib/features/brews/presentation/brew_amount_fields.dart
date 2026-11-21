import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_field.dart';

/// The dose, purge and yield fields of the brew form (grams).
class BrewAmountFields extends StatelessWidget {
  /// Creates the fields around the three controllers.
  const BrewAmountFields({
    required this.dose,
    required this.purge,
    required this.yieldG,
    required this.errors,
    required this.onPurgeEdited,
    super.key,
  });

  /// Dose text.
  final TextEditingController dose;

  /// Purge text.
  final TextEditingController purge;

  /// Yield text.
  final TextEditingController yieldG;

  /// Error lines by field key (`dose`, `purge`, `yield`).
  final Map<String, String> errors;

  /// Called when the user types into the purge field, which stops it from
  /// following the purge advice.
  final VoidCallback onPurgeEdited;

  Widget _field(
    BuildContext context,
    String name,
    String label,
    TextEditingController controller, {
    VoidCallback? onEdited,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: Tokens.space16),
    child: Semantics(
      container: true,
      child: AppField(
        key: Key('field-$name'),
        label: label,
        controller: controller,
        unit: context.l10n.unitG,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        errorText: errors[name],
        onChanged: onEdited == null ? null : (_) => onEdited(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        _field(context, 'dose', l.brewDose, dose),
        _field(context, 'purge', l.brewPurge, purge, onEdited: onPurgeEdited),
        _field(context, 'yield', l.brewYield, yieldG),
      ],
    );
  }
}
