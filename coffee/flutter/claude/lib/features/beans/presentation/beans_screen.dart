import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/add_action.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/link_card.dart';
import '../../../core/widgets/page_body.dart';

/// Bohnen list; content follows in a later story.
class BeansScreen extends StatelessWidget {
  /// Creates the screen.
  const BeansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      section: AppSection.beans,
      title: l.beans,
      actions: [AddAction(route: AppRoutes.beanNew, label: l.beanForm)],
      body: PageBody(
        children: [
          ComingSoon(title: l.beans),
          LinkCard(
            label: l.openBeanDetail,
            icon: Icons.coffee,
            route: AppRoutes.beanDetail,
          ),
        ],
      ),
    );
  }
}
