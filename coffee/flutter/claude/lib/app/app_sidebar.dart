import 'package:material_ui/material_ui.dart';

import '../core/l10n_context.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/tokens.dart';
import 'app_section.dart';
import 'sidebar_item.dart';

/// Fixed 240 dp sidebar with 7 entries (desktop, >= 1024 dp). Fills the
/// viewport height.
class AppSidebar extends StatelessWidget {
  /// Creates the sidebar.
  const AppSidebar({required this.current, super.key});

  /// Active section.
  final AppSection current;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l = context.l10n;
    return Semantics(
      container: true,
      label: l.navigation,
      child: DecoratedBox(
        key: const Key('app-sidebar'),
        decoration: BoxDecoration(
          color: c.surfaceVariant,
          border: Border(
            right: BorderSide(color: c.border, width: Tokens.borderWidth),
          ),
        ),
        child: SizedBox(
          width: Tokens.sidebarWidth,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(Tokens.space16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Tokens.space16,
                    horizontal: Tokens.space12,
                  ),
                  child: Text(
                    l.appTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                for (final s in AppSection.wide)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Tokens.space4),
                    child: SidebarItem(
                      itemKey: Key(s.keyName),
                      icon: s.icon,
                      label: s.label(l),
                      selected: s == current,
                      onTap: () {
                        if (s != current) s.open(context);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
