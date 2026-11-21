import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/rules/rule_entry.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rule_source_label.dart';
import '../../water/domain/water_checker.dart';
import '../domain/brew.dart';
import '../domain/recommendation.dart';
import 'recommendation_text.dart';

/// "Recommendation" card of the brew detail: one sentence, the reason and the
/// source (URL as link-style text, or "Default without source").
class RecommendationCard extends StatelessWidget {
  /// Creates the card for [recommendation] of [brew].
  const RecommendationCard({
    required this.recommendation,
    required this.brew,
    required this.checker,
    super.key,
  });

  /// Advice to show.
  final Recommendation recommendation;

  /// Brew the advice is for.
  final Brew brew;

  /// Water ranges for the water sentence.
  final WaterChecker checker;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final r = recommendation;
    const gap = SizedBox(height: Tokens.space12);
    return AppCard(
      key: const Key('recommendation-card'),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.recTitle, style: text.labelLarge),
            const SizedBox(height: Tokens.space4),
            Text(
              RecommendationText.sentence(l, r, checker),
              key: const Key('rec-sentence'),
              style: text.titleLarge,
            ),
            if (r.reason == ReasonCode.scaleEnd)
              Text(
                l.recScaleEndHint,
                key: const Key('rec-hint'),
                style: text.bodyMedium!.copyWith(color: c.warning),
              ),
            gap,
            Text(l.recReasonTitle, style: text.labelLarge),
            Text(
              RecommendationText.reason(l, r, brew),
              key: const Key('rec-reason'),
              style: text.bodyMedium,
            ),
            gap,
            Text(l.recSourceTitle, style: text.labelLarge),
            if (r.source == 'none')
              const RuleSourceLabel(
                key: Key('rec-source'),
                entry: RuleEntry(
                  key: '',
                  value: null,
                  source: 'none',
                  retrieved: '',
                ),
              )
            else
              SelectableText(
                r.source,
                key: const Key('rec-source'),
                style: text.bodySmall!.copyWith(
                  color: c.accent,
                  decoration: TextDecoration.underline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
