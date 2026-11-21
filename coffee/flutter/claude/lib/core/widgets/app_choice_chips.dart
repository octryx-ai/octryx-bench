import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Single-choice pill selector (e.g. hardness unit, grind direction).
class AppChoiceChips<T> extends StatelessWidget {
  /// Creates the selector; [labels] keeps its insertion order.
  const AppChoiceChips({
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.keyPrefix = 'choice',
    super.key,
  });

  /// Option value to visible label.
  final Map<T, String> labels;

  /// Currently selected option, or null if none is chosen.
  final T? selected;

  /// Called when another option is tapped.
  final ValueChanged<T> onSelected;

  /// Prefix of each chip key (`<prefix>-<value>`).
  final String keyPrefix;

  static String _name(Object? value) => value is Enum ? value.name : '$value';

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(Tokens.radiusChip);
    return Wrap(
      spacing: Tokens.space8,
      runSpacing: Tokens.space8,
      children: [
        for (final entry in labels.entries)
          Semantics(
            button: true,
            selected: entry.key == selected,
            label: entry.value,
            excludeSemantics: true,
            child: Material(
              color: entry.key == selected
                  ? c.accent.withValues(alpha: Tokens.tintAlpha)
                  : c.surface,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(
                  color: entry.key == selected ? c.accent : c.border,
                  width: entry.key == selected
                      ? Tokens.selectedBorderWidth
                      : Tokens.borderWidth,
                ),
              ),
              child: InkWell(
                key: Key('$keyPrefix-${_name(entry.key)}'),
                borderRadius: radius,
                onTap: () => onSelected(entry.key),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: Tokens.touchTarget,
                    minWidth: Tokens.touchTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Tokens.space16,
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        entry.value,
                        style: text.labelLarge!.copyWith(
                          color: entry.key == selected ? c.accent : c.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
