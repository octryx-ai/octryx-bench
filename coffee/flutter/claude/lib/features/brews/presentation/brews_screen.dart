import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/add_action.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import 'brew_card.dart';

/// Brühen: the "Filter starten" entry and the list of brews, newest first,
/// or the empty state. The list is lazy and every row has a fixed extent, so
/// a thousand brews cost no more than the visible window.
class BrewsScreen extends StatelessWidget {
  /// Creates the screen.
  const BrewsScreen({super.key});

  static const double _rowExtent = Tokens.listCardHeight + Tokens.space12;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = AppScope.of(context);
    final brews = data.brews;
    return AppShell(
      section: AppSection.brews,
      title: l.brew,
      actions: [AddAction(route: AppRoutes.brewNew, label: l.brewForm)],
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Tokens.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(Tokens.space16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppButton(
                    key: const Key('start-filter'),
                    label: l.startFilter,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.filter),
                  ),
                ),
              ),
              Expanded(
                child: brews.isEmpty
                    ? EmptyState(
                        icon: Icons.local_cafe,
                        title: l.brewsEmptyTitle,
                        body: l.brewsEmptyBody,
                        actionLabel: l.brewForm,
                        onAction: () =>
                            Navigator.of(context).pushNamed(AppRoutes.brewNew),
                      )
                    : ListView.builder(
                        key: const Key('brew-list'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Tokens.space16,
                        ),
                        itemExtent: _rowExtent,
                        itemCount: brews.length,
                        itemBuilder: (context, i) {
                          final brew = brews[i];
                          final pack = data.packById(brew.packId);
                          final bean = pack == null
                              ? null
                              : data.beanById(pack.beanId);
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: Tokens.space12,
                            ),
                            child: BrewCard(
                              brew: brew,
                              beanName: bean?.name ?? '–',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
