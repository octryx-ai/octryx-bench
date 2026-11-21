import 'package:material_ui/material_ui.dart';

import '../l10n_context.dart';
import 'app_chip.dart';
import 'chip_tone.dart';

/// Chip for a pack's readiness: Ready, Resting N days, Too old.
class ReadinessChip extends StatelessWidget {
  /// Chip "Ready".
  const ReadinessChip.ready({super.key}) : restingDays = null, tooOld = false;

  /// Chip "Resting, [days] days left".
  const ReadinessChip.resting({required int days, super.key})
    : restingDays = days,
      tooOld = false;

  /// Chip "Too old".
  const ReadinessChip.tooOld({super.key}) : restingDays = null, tooOld = true;

  /// Remaining resting days, null when not resting.
  final int? restingDays;

  /// Whether the pack is too old.
  final bool tooOld;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final days = restingDays;
    if (tooOld) {
      return AppChip(
        label: l.tooOld,
        tone: ChipTone.error,
        icon: Icons.warning_amber,
      );
    }
    if (days != null) {
      return AppChip(
        label: l.restingDays(days),
        tone: ChipTone.warning,
        icon: Icons.hourglass_bottom,
      );
    }
    return AppChip(
      label: l.ready,
      tone: ChipTone.success,
      icon: Icons.check_circle_outline,
    );
  }
}
