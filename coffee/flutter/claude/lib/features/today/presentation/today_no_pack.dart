import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../beans/domain/bean.dart';

/// Heute group "Ohne Packung": beans without a live pack, each with the hint
/// to add a pack. Tapping a row opens the pack form of that bean.
class TodayNoPackSection extends StatelessWidget {
  /// Creates the group for [beans]; the caller shows it only when not empty.
  const TodayNoPackSection({required this.beans, super.key});

  /// Beans without a live pack, in list order.
  final List<Bean> beans;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.todayNoPackTitle,
          key: const Key('today-no-pack-title'),
          style: text.titleLarge,
        ),
        const SizedBox(height: Tokens.space12),
        for (final bean in beans)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.space12),
            child: _NoPackRow(bean: bean),
          ),
      ],
    );
  }
}

/// One bean of the group: name and the "Add a pack" hint.
class _NoPackRow extends StatelessWidget {
  const _NoPackRow({required this.bean});

  final Bean bean;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return AppCard(
      key: Key('today-no-pack-${bean.id}'),
      semanticLabel: bean.name,
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.space16,
        vertical: Tokens.space12,
      ),
      onTap: () =>
          Navigator.of(context)
              .pushNamed(AppRoutes.packNew, arguments: bean.id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bean.name,
            style: text.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(l.todayNoPackHint, style: text.bodySmall),
        ],
      ),
    );
  }
}
