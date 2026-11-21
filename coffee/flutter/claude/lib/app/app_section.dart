import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'app_routes.dart';

/// Top-level destination of the app shell.
enum AppSection {
  /// Heute.
  today(AppRoutes.today, 'nav-today', Icons.today),

  /// Bohnen.
  beans(AppRoutes.beans, 'nav-beans', Icons.coffee),

  /// Brühen.
  brews(AppRoutes.brews, 'nav-brews', Icons.local_cafe),

  /// Ausrüstung.
  equipment(
    AppRoutes.equipment,
    'nav-equipment',
    Icons.settings_input_component,
  ),

  /// Wasser.
  water(AppRoutes.water, 'nav-water', Icons.water_drop),

  /// Pflege.
  care(AppRoutes.care, 'nav-care', Icons.cleaning_services),

  /// Einstellungen.
  settings(AppRoutes.settings, 'nav-settings', Icons.settings),

  /// Mehr (phone and tablet menu).
  more(AppRoutes.more, 'nav-more', Icons.more_horiz);

  const AppSection(this.route, this.keyName, this.icon);

  /// Route name of the section.
  final String route;

  /// Stable key name for tests and automation.
  final String keyName;

  /// Navigation icon.
  final IconData icon;

  /// Destinations of the phone bottom bar and the tablet rail.
  static const List<AppSection> compact = [
    today,
    beans,
    brews,
    equipment,
    more,
  ];

  /// Destinations of the desktop sidebar.
  static const List<AppSection> wide = [
    today,
    beans,
    brews,
    equipment,
    water,
    care,
    settings,
  ];

  /// The compact destination this section belongs to.
  AppSection get compactParent =>
      this == water || this == care || this == settings ? more : this;

  /// Localized label.
  String label(AppLocalizations l) => switch (this) {
    today => l.today,
    beans => l.beans,
    brews => l.brew,
    equipment => l.equipment,
    water => l.water,
    care => l.care,
    settings => l.settings,
    more => l.more,
  };

  /// Replaces the current section page with this section.
  void open(BuildContext context) =>
      Navigator.of(context).pushReplacementNamed(route);
}
