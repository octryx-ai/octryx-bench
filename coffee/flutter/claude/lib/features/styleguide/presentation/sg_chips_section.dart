import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/readiness_chip.dart';
import 'sg_section.dart';
import 'sg_state.dart';

/// Style-guide: readiness chips.
class SgChipsSection extends StatelessWidget {
  /// Creates the section.
  const SgChipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SgSection(
      title: l.sgChips,
      children: [
        SgState(
          keyName: 'chip-ready',
          label: l.ready,
          child: const ReadinessChip.ready(),
        ),
        SgState(
          keyName: 'chip-resting',
          label: l.restingDays(3),
          child: const ReadinessChip.resting(days: 3),
        ),
        SgState(
          keyName: 'chip-tooold',
          label: l.tooOld,
          child: const ReadinessChip.tooOld(),
        ),
      ],
    );
  }
}
