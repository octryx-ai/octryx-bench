import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/add_action.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/link_card.dart';
import '../../../core/widgets/page_body.dart';

/// Brühen list with the "Filter starten" entry; list follows in a later story.
class BrewsScreen extends StatelessWidget {
  /// Creates the screen.
  const BrewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      section: AppSection.brews,
      title: l.brew,
      actions: [AddAction(route: AppRoutes.brewNew, label: l.brewForm)],
      body: PageBody(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              key: const Key('start-filter'),
              label: l.startFilter,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.filter),
            ),
          ),
          const SizedBox(height: Tokens.space16),
          ComingSoon(title: l.brew),
          LinkCard(
            label: l.openBrewDetail,
            icon: Icons.local_cafe,
            route: AppRoutes.brewDetail,
          ),
        ],
      ),
    );
  }
}
