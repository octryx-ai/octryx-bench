/// Deterministic, path-like route names (also used as web hash routes).
abstract final class AppRoutes {
  /// Heute (home).
  static const String today = '/';

  /// Bohnen list.
  static const String beans = '/beans';

  /// Bohnendetail.
  static const String beanDetail = '/beans/detail';

  /// Bohnenformular.
  static const String beanNew = '/beans/new';

  /// Brühungen list.
  static const String brews = '/brews';

  /// Brühungsformular.
  static const String brewNew = '/brews/new';

  /// Brühungsdetail.
  static const String brewDetail = '/brews/detail';

  /// Filter geführt (focus mode).
  static const String filter = '/filter';

  /// Ausrüstung with tabs.
  static const String equipment = '/equipment';

  /// Mühlenformular.
  static const String grinderNew = '/equipment/grinder/new';

  /// Maschinenformular.
  static const String machineNew = '/equipment/machine/new';

  /// Mehr menu.
  static const String more = '/more';

  /// Wasser.
  static const String water = '/water';

  /// Wasserformular.
  static const String waterNew = '/water/new';

  /// Pflege.
  static const String care = '/care';

  /// Einstellungen.
  static const String settings = '/settings';

  /// Style-guide page.
  static const String styleGuide = '/styleguide';
}
