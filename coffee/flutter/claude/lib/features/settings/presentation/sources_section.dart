import 'package:material_ui/material_ui.dart';

import '../../../app/app_services.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rule_source_label.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/rule_source_group.dart';

/// "Sources": all rule entries of the asset files grouped by file, each with
/// its key, value and source (URL or "Default without source").
class SourcesSection extends StatefulWidget {
  /// Creates the section.
  const SourcesSection({super.key});

  @override
  State<SourcesSection> createState() => _SourcesSectionState();
}

class _SourcesSectionState extends State<SourcesSection> {
  Future<List<RuleSourceGroup>>? _groups;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _groups ??= AppServicesScope.of(context).sources.load();
  }

  static String _groupTitle(AppLocalizations l, String asset) =>
      switch (asset) {
        'assets/water_rules.json' => l.water,
        'assets/rest_rules.json' => l.sourcesGroupRest,
        'assets/care_rules.json' => l.care,
        _ => l.brew,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Column(
      key: const Key('settings-sources'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.sourcesTitle, style: text.titleMedium),
        const SizedBox(height: Tokens.space8),
        FutureBuilder<List<RuleSourceGroup>>(
          future: _groups,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(l.sourcesLoadError);
            final groups = snapshot.data;
            if (groups == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final g in groups) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Tokens.space8,
                    ),
                    child: Text(
                      _groupTitle(l, g.asset),
                      style: text.titleSmall,
                    ),
                  ),
                  for (final e in g.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Tokens.space8),
                      child: AppCard(
                        key: Key('source-${e.key}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key, style: text.labelLarge),
                            Text('${e.value}', style: text.bodyMedium),
                            RuleSourceLabel(entry: e),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
