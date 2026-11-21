import 'package:material_ui/material_ui.dart';

import '../../../../core/format/app_format.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/tokens.dart';
import '../../domain/filter_recipe_calculator.dart';

/// Ratio slider (1:14 to 1:18 in 0.5 steps) with its value label and the
/// live total water line.
class FilterRatioField extends StatelessWidget {
  /// Creates the field; [waterG] is null while the dose is invalid.
  const FilterRatioField({
    required this.calculator,
    required this.ratio,
    required this.waterG,
    required this.onChanged,
    super.key,
  });

  /// Source of range, step and snapping.
  final FilterRecipeCalculator calculator;

  /// Current ratio.
  final double ratio;

  /// Total water in grams, or null.
  final double? waterG;

  /// Called with the snapped ratio.
  final ValueChanged<double> onChanged;

  /// Ratio as `1:16` or `1:16.5`.
  static String label(double ratio) => '1:${AppFormat.plain(ratio)}';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final span = calculator.maxRatio - calculator.minRatio;
    final water = waterG;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.filterRatio, style: text.labelLarge)),
            Text(
              label(ratio),
              key: const Key('filter-ratio-value'),
              style: text.titleMedium,
            ),
          ],
        ),
        Slider(
          key: const Key('filter-ratio'),
          min: calculator.minRatio,
          max: calculator.maxRatio,
          divisions: (span / calculator.ratioStep).round(),
          value: ratio,
          label: label(ratio),
          semanticFormatterCallback: label,
          onChanged: (v) => onChanged(calculator.normalizeRatio(v)),
        ),
        const SizedBox(height: Tokens.space4),
        Text(
          water == null ? '–' : l.filterWaterTotal(AppFormat.plain(water)),
          key: const Key('filter-water-total'),
          style: text.titleMedium,
        ),
      ],
    );
  }
}
