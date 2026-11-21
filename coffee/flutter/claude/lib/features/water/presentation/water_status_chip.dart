import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/chip_tone.dart';

/// Chip "In SCA range" (success) or "Outside SCA" (error).
class WaterStatusChip extends StatelessWidget {
  /// Creates the chip.
  const WaterStatusChip({required this.inRange, super.key});

  /// Whether all measured parameters are in the SCA range.
  final bool inRange;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppChip(
      label: inRange ? l.waterInScaRange : l.waterOutsideSca,
      tone: inRange ? ChipTone.success : ChipTone.error,
      icon: inRange ? Icons.check_circle_outline : Icons.error_outline,
    );
  }
}
