import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/delete_action.dart';
import '../../../core/widgets/page_body.dart';
import 'brew_format.dart';
import 'brew_header.dart';
import 'brew_tiles.dart';
import 'recommendation_card.dart';

/// Detail of a brew: header band, key figures, the recommendation card and
/// the "Next try" action.
class BrewDetailScreen extends StatelessWidget {
  /// Creates the detail of the brew with [brewId].
  const BrewDetailScreen({required this.brewId, super.key});

  /// Id of the brew shown.
  final String? brewId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = AppScope.of(context);
    final id = brewId;
    final brew = id == null ? null : data.brewById(id);
    final pack = brew == null ? null : data.packById(brew.packId);
    final bean = pack == null ? null : data.beanById(pack.beanId);
    if (brew == null || brew.isDeleted || bean == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.brewDetail)),
        body: Center(child: Text(l.brewNotFound)),
      );
    }
    final recommendation = data.recommendFor(brew);
    final name = '${BrewFormat.method(l, brew.method)}, ${bean.name}';
    return Scaffold(
      appBar: AppBar(
        title: Text(l.brewDetail),
        actions: [
          DeleteAction(
            name: name,
            onDelete: () {
              final navigator = Navigator.of(context);
              data.deleteBrew(brew.id);
              navigator.pop();
            },
          ),
        ],
      ),
      body: PageBody(
        children: [
          BrewHeader(brew: brew, beanName: bean.name),
          const SizedBox(height: Tokens.space16),
          BrewTiles(brew: brew, data: data),
          const SizedBox(height: Tokens.space24),
          RecommendationCard(
            recommendation: recommendation,
            brew: brew,
            checker: data.checker,
          ),
          const SizedBox(height: Tokens.space16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              key: const Key('next-try'),
              label: l.nextTry,
              onPressed: () => Navigator.of(context).pushNamed(
                brew.method.isFilter ? AppRoutes.filter : AppRoutes.brewNew,
                arguments: brew.id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
