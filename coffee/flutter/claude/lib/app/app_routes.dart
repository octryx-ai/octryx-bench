/// Deterministic, path-like route names (also used as web hash routes).
abstract final class AppRoutes {
  /// Heute (home).
  static const String today = '/';

  /// Onboarding page 1 (first start, full screen); not part of the shell.
  static const String onboarding = '/onboarding';

  /// Bohnen list.
  static const String beans = '/beans';

  /// Bohnendetail.
  static const String beanDetail = '/beans/detail';

  /// Bohnenformular.
  static const String beanNew = '/beans/new';

  /// Bohnenformular zum Bearbeiten; argument: bean id.
  static const String beanEdit = '/beans/edit';

  /// Packungsformular; argument: bean id.
  static const String packNew = '/beans/pack/new';

  /// Packungsformular zum Bearbeiten; argument: pack id.
  static const String packEdit = '/beans/pack/edit';

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

  /// Mühlenformular zum Bearbeiten; argument: grinder id.
  static const String grinderEdit = '/equipment/grinder/edit';

  /// Maschinenformular.
  static const String machineNew = '/equipment/machine/new';

  /// Maschinenformular zum Bearbeiten; argument: machine id.
  static const String machineEdit = '/equipment/machine/edit';

  /// Mehr menu.
  static const String more = '/more';

  /// Wasser.
  static const String water = '/water';

  /// Wasserformular.
  static const String waterNew = '/water/new';

  /// Wasserdetail; argument: water profile id.
  static const String waterDetail = '/water/detail';

  /// Wasserformular zum Bearbeiten; argument: water profile id.
  static const String waterEdit = '/water/edit';

  /// Pflege.
  static const String care = '/care';

  /// Einstellungen.
  static const String settings = '/settings';

  /// Style-guide page.
  static const String styleGuide = '/styleguide';
}
