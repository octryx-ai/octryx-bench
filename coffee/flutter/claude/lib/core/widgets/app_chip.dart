import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'chip_tone.dart';

/// Pill chip with icon and text in a status tone (never colour alone).
class AppChip extends StatelessWidget {
  /// Creates a chip.
  const AppChip({
    required this.label,
    required this.tone,
    required this.icon,
    super.key,
  });

  /// Chip text.
  final String label;

  /// Status tone.
  final ChipTone tone;

  /// Leading icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = switch (tone) {
      ChipTone.success => c.success,
      ChipTone.warning => c.warning,
      ChipTone.error => c.error,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Tokens.radiusChip),
        border: Border.all(color: color, width: Tokens.borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Tokens.space12,
          vertical: Tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: Tokens.fontSize16, color: color),
            const SizedBox(width: Tokens.space4),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium!
                    .copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
