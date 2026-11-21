import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_field.dart';
import '../../equipment/domain/grinder.dart';
import 'brew_format.dart';

/// Grind setting input: a text field with minus and plus buttons that move
/// the value by one step of the grinder's scale (snapped to the scale grid
/// and clamped to its ends).
class GrindStepper extends StatelessWidget {
  /// Creates the stepper for [grinder] editing [controller].
  const GrindStepper({
    required this.grinder,
    required this.controller,
    this.errorText,
    super.key,
  });

  /// Grinder whose scale applies.
  final Grinder grinder;

  /// Holds the setting text.
  final TextEditingController controller;

  /// Error line under the field.
  final String? errorText;

  void _bump(int direction) {
    final g = grinder;
    final current = AppFormat.parse(controller.text) ?? g.scaleMin;
    final steps = ((current - g.scaleMin) / g.scaleStep).round() + direction;
    final next = (g.scaleMin + steps * g.scaleStep).clamp(
      g.scaleMin,
      g.scaleMax,
    );
    controller.text = BrewFormat.setting(double.parse(next.toStringAsFixed(6)));
  }

  Widget _button(
    BuildContext context, {
    required String id,
    required IconData icon,
    required String label,
    required int direction,
  }) => IconButton(
    key: Key(id),
    tooltip: label,
    constraints: const BoxConstraints(
      minWidth: Tokens.touchTarget,
      minHeight: Tokens.touchTarget,
    ),
    icon: Semantics(
      label: label,
      child: Icon(icon, color: AppColors.of(context).accent),
    ),
    onPressed: () => _bump(direction),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppField(
      key: const Key('field-grind'),
      label: l.brewGrind,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      errorText: errorText,
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            context,
            id: 'grind-minus',
            icon: Icons.remove,
            label: l.grindLower,
            direction: -1,
          ),
          _button(
            context,
            id: 'grind-plus',
            icon: Icons.add,
            label: l.grindRaise,
            direction: 1,
          ),
        ],
      ),
    );
  }
}
