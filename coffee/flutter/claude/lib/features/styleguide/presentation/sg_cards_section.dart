import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/visual_state.dart';
import 'sg_section.dart';
import 'sg_state.dart';

/// Style-guide: cards in every state.
class SgCardsSection extends StatelessWidget {
  /// Creates the section.
  const SgCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    Widget content() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.cardTitle, style: text.titleMedium),
        Text(l.cardBody, style: text.bodyMedium),
      ],
    );
    Widget tile(String key, String label, Widget card) =>
        SgState(keyName: 'card-$key', label: label, child: card);
    return SgSection(
      title: l.sgCards,
      children: [
        tile(
          'default',
          l.stateDefault,
          AppCard(onTap: () {}, child: content()),
        ),
        tile(
          'hover',
          l.stateHover,
          AppCard(state: VisualState.hover, child: content()),
        ),
        tile(
          'selected',
          l.stateSelected,
          AppCard(state: VisualState.selected, child: content()),
        ),
        tile(
          'disabled',
          l.stateDisabled,
          AppCard(state: VisualState.disabled, child: content()),
        ),
        tile(
          'empty',
          l.stateEmpty,
          AppCard(
            child: EmptyState(
              icon: Icons.coffee,
              title: l.emptyTitle,
              body: l.emptyBody,
              actionLabel: l.addBean,
              onAction: () {},
            ),
          ),
        ),
        tile('loading', l.stateLoading, const AppCard.loading()),
        tile(
          'error',
          l.stateError,
          AppCard.error(message: l.errorBody, onRetry: () {}),
        ),
      ],
    );
  }
}
