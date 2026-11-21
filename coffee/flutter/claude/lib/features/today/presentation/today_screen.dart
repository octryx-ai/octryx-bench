import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import '../../beans/presentation/bean_card.dart';
import '../../brews/presentation/brew_card.dart';
import '../../care/presentation/care_tile.dart';
import 'today_warnings.dart';

/// Heute: warning banners, beans that are ready now, the last brew and the
/// care tile; the floating button starts a new brew. Without beans the empty
/// state invites to add the first one.
class TodayScreen extends StatelessWidget {
  /// Creates the screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final data = AppScope.of(context);
    final navigator = Navigator.of(context);
    final ready = data.readyNowSummaries;
    final last = data.lastBrew;
    final lastBean = last == null
        ? null
        : data.beanById(data.packById(last.packId)?.beanId ?? '');
    final Widget body;
    if (data.beans.isEmpty) {
      body = Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(Tokens.space16),
            child: CareTile(),
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.coffee,
              title: l.emptyTitle,
              body: l.emptyBody,
              actionLabel: l.addBean,
              onAction: () => navigator.pushNamed(AppRoutes.beanNew),
            ),
          ),
        ],
      );
    } else {
      body = PageBody(
        children: [
          TodayWarnings(warnings: data.warnings),
          const CareTile(),
          const SizedBox(height: Tokens.space24),
          Text(l.todayReadyNow, style: text.titleLarge),
          const SizedBox(height: Tokens.space12),
          if (ready.isEmpty)
            Text(
              l.todayReadyNone,
              key: const Key('today-ready-none'),
              style: text.bodyMedium,
            )
          else
            for (final s in ready)
              Padding(
                padding: const EdgeInsets.only(bottom: Tokens.space12),
                child: BeanCard(summary: s),
              ),
          const SizedBox(height: Tokens.space12),
          Text(l.todayLastBrew, style: text.titleLarge),
          const SizedBox(height: Tokens.space12),
          if (last == null)
            Text(
              l.todayLastNone,
              key: const Key('today-last-none'),
              style: text.bodyMedium,
            )
          else
            BrewCard(brew: last, beanName: lastBean?.name ?? '–'),
          const SizedBox(height: Tokens.space48 + Tokens.space32),
        ],
      );
    }
    return AppShell(
      section: AppSection.today,
      title: l.today,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('today-new-brew'),
        heroTag: null,
        icon: const Icon(Icons.add),
        label: Text(l.todayNewBrew),
        onPressed: () => navigator.pushNamed(AppRoutes.brewNew),
      ),
      body: body,
    );
  }
}
