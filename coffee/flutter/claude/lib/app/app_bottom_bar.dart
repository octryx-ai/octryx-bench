import 'package:material_ui/material_ui.dart';

import '../core/l10n_context.dart';
import 'app_section.dart';

/// Phone bottom navigation with 5 destinations.
class AppBottomBar extends StatelessWidget {
  /// Creates the bar.
  const AppBottomBar({required this.current, super.key});

  /// Active section.
  final AppSection current;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = AppSection.compact;
    return NavigationBar(
      selectedIndex: items.indexOf(current.compactParent),
      onDestinationSelected: (i) {
        if (items[i] != current) items[i].open(context);
      },
      destinations: [
        for (final s in items)
          NavigationDestination(
            key: Key(s.keyName),
            icon: Icon(s.icon),
            label: s.label(l),
          ),
      ],
    );
  }
}
