import 'package:material_ui/material_ui.dart';

import '../format/app_format.dart';
import '../l10n_context.dart';
import '../rules/rule_entry.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Shows where a rule value comes from: the source URL with retrieval date,
/// or "Default without source" for entries with source `none`.
class RuleSourceLabel extends StatelessWidget {
  /// Creates the label for [entry].
  const RuleSourceLabel({required this.entry, super.key});

  /// Rule entry to describe.
  final RuleEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final style = Theme.of(context).textTheme.bodySmall!;
    if (!entry.hasSource) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline, size: Tokens.fontSize16, color: c.warning),
          const SizedBox(width: Tokens.space4),
          Flexible(
            child: Text(
              l.defaultWithoutSource,
              style: style.copyWith(color: c.warning),
            ),
          ),
        ],
      );
    }
    final parsed = DateTime.tryParse(entry.retrieved);
    final date = parsed == null
        ? entry.retrieved
        : AppFormat.of(context).date(parsed);
    return Text(
      l.sourceLabel(entry.source, date),
      style: style.copyWith(color: c.accent),
    );
  }
}
