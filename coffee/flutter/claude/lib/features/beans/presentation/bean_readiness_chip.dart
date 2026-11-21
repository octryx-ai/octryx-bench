import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/readiness_chip.dart';
import '../domain/pack_readiness.dart';

/// Readiness chip for a [PackReadiness]: Ready, Resting N days or Too old.
class BeanReadinessChip extends StatelessWidget {
  /// Creates the chip.
  const BeanReadinessChip({required this.readiness, super.key});

  /// Readiness to show.
  final PackReadiness readiness;

  @override
  Widget build(BuildContext context) => switch (readiness.status) {
    ReadinessStatus.ready => const ReadinessChip.ready(),
    ReadinessStatus.resting => ReadinessChip.resting(days: readiness.daysLeft),
    ReadinessStatus.tooOld => const ReadinessChip.tooOld(),
  };
}
