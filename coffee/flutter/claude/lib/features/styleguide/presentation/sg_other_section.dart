import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/rules/rule_entry.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/rule_source_label.dart';
import 'sg_section.dart';
import 'sg_state.dart';

/// Style-guide: empty state, coming-soon notice and rule source labels.
class SgOtherSection extends StatelessWidget {
  /// Creates the section.
  const SgOtherSection({super.key});

  static const _withoutSource = RuleEntry(
    key: 'demo.none',
    value: 24,
    source: 'none',
    retrieved: '2026-11-16',
  );

  static const _withSource = RuleEntry(
    key: 'demo.source',
    value: 7,
    source: 'https://example.org/rules',
    retrieved: '2026-11-16',
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SgSection(
      title: l.sgOther,
      children: [
        SgState(
          keyName: 'empty-state',
          label: l.stateEmpty,
          child: EmptyState(
            icon: Icons.coffee,
            title: l.emptyTitle,
            body: l.emptyBody,
            actionLabel: l.addBean,
            onAction: () {},
          ),
        ),
        SgState(
          keyName: 'coming-soon',
          label: l.comingSoon,
          child: ComingSoon(title: l.styleGuide),
        ),
        SgState(
          keyName: 'rule-none',
          label: l.defaultWithoutSource,
          child: const RuleSourceLabel(entry: _withoutSource),
        ),
        SgState(
          keyName: 'rule-source',
          label: l.ruleDemoKey,
          child: const RuleSourceLabel(entry: _withSource),
        ),
      ],
    );
  }
}
