import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/tokens.dart';
import 'app_bottom_bar.dart';
import 'app_rail.dart';
import 'app_section.dart';
import 'app_sidebar.dart';

/// Responsive shell: bottom bar (phone), rail (tablet) or fixed sidebar
/// (desktop), with title and actions on top. Always fills the viewport.
class AppShell extends StatelessWidget {
  /// Creates the shell around [body].
  const AppShell({
    required this.section,
    required this.title,
    required this.body,
    this.actions = const [],
    this.bottom,
    super.key,
  });

  /// Active section.
  final AppSection section;

  /// Page title.
  final String title;

  /// Page content.
  final Widget body;

  /// Top-bar actions.
  final List<Widget> actions;

  /// Optional widget under the title (tabs).
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final page = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        actions: actions,
        bottom: bottom,
      ),
      body: body,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final Widget content;
        if (width >= Tokens.breakpointDesktop) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSidebar(current: section),
              Expanded(child: page),
            ],
          );
        } else if (width >= Tokens.breakpointTablet) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppRail(current: section),
              Expanded(child: page),
            ],
          );
        } else {
          content = Column(
            children: [
              Expanded(child: page),
              AppBottomBar(current: section),
            ],
          );
        }
        return Scaffold(
          backgroundColor: AppColors.of(context).surface,
          body: SizedBox(height: constraints.maxHeight, child: content),
        );
      },
    );
  }
}
