import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/add_action.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/page_body.dart';

/// Wasser; content follows in a later story.
class WaterScreen extends StatelessWidget {
  /// Creates the screen.
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      section: AppSection.water,
      title: l.water,
      actions: [AddAction(route: AppRoutes.waterNew, label: l.waterForm)],
      body: PageBody(children: [ComingSoon(title: l.water)]),
    );
  }
}
