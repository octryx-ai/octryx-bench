import 'package:material_ui/material_ui.dart';

import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/page_body.dart';

/// Pflege; content follows in a later story.
class CareScreen extends StatelessWidget {
  /// Creates the screen.
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppShell(
      section: AppSection.care,
      title: l.care,
      body: PageBody(children: [ComingSoon(title: l.care)]),
    );
  }
}
