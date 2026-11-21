import 'package:material_ui/material_ui.dart';

import '../core/l10n_context.dart';
import 'app_section.dart';

/// Tablet navigation rail with the same 5 destinations as the bottom bar.
class AppRail extends StatelessWidget {
  /// Creates the rail.
  const AppRail({required this.current, super.key});

  /// Active section.
  final AppSection current;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = AppSection.compact;
    return NavigationRail(
      selectedIndex: items.indexOf(current.compactParent),
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: (i) {
        if (items[i] != current) items[i].open(context);
      },
      destinations: [
        for (final s in items)
          NavigationRailDestination(
            icon: Icon(s.icon, key: Key(s.keyName)),
            label: Text(s.label(l)),
          ),
      ],
    );
  }
}
