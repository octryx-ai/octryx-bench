import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/link_card.dart';
import '../../../core/widgets/page_body.dart';

/// Heute (home); content follows in a later story.
class TodayScreen extends StatelessWidget {
  /// Creates the screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      section: AppSection.today,
      title: l.today,
      body: PageBody(
        children: [
          ComingSoon(title: l.today),
          LinkCard(
            label: l.care,
            icon: Icons.cleaning_services,
            route: AppRoutes.care,
          ),
        ],
      ),
    );
  }
}
