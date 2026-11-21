import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_field.dart';
import 'pack_input.dart';
import 'roast_date_field.dart';

/// Roast date and weight fields of a pack.
class PackFields extends StatelessWidget {
  /// Creates the fields bound to [input].
  const PackFields({
    required this.input,
    required this.today,
    this.result,
    super.key,
  });

  /// Controllers.
  final PackInput input;

  /// Today (date-only).
  final DateTime today;

  /// Latest validation result; its errors are shown under the fields.
  final PackInputResult? result;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          child: RoastDateField(
            key: const Key('field-roastDate'),
            controller: input.roastDate,
            today: today,
            errorText: result?.dateError,
          ),
        ),
        const SizedBox(height: Tokens.space16),
        Semantics(
          container: true,
          child: AppField(
            key: const Key('field-weight'),
            label: l.fieldWeight,
            controller: input.weight,
            unit: l.unitG,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: result?.sizeError,
          ),
        ),
      ],
    );
  }
}
