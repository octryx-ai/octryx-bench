import 'package:material_ui/material_ui.dart';

import '../core/l10n_context.dart';
import '../features/beans/presentation/bean_detail_screen.dart';
import '../features/beans/presentation/bean_form_screen.dart';
import '../features/beans/presentation/beans_screen.dart';
import '../features/beans/presentation/pack_form_screen.dart';
import '../features/brews/presentation/brew_detail_screen.dart';
import '../features/brews/presentation/brew_form_screen.dart';
import '../features/brews/presentation/brews_screen.dart';
import '../features/care/presentation/care_screen.dart';
import '../features/equipment/presentation/equipment_screen.dart';
import '../features/equipment/presentation/grinder_form_screen.dart';
import '../features/equipment/presentation/machine_form_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/styleguide/presentation/styleguide_screen.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/water/presentation/water_detail_screen.dart';
import '../features/water/presentation/water_form_screen.dart';
import '../features/water/presentation/water_screen.dart';
import '../l10n/app_localizations.dart';
import 'app_routes.dart';
import 'sub_page.dart';

/// Maps route names to pages. Section pages switch without animation.
abstract final class AppRouter {
  /// `onGenerateRoute` callback; unknown routes fall back to Heute.
  static Route<void> onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final section = _sections[name];
    if (section != null) {
      return PageRouteBuilder<void>(
        settings: settings,
        pageBuilder: (_, _, _) => section(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    }
    final title = _subPageTitles[name];
    final page = _pages[name];
    final id = settings.arguments as String?;
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => page != null
          ? page(id)
          : name == AppRoutes.styleGuide
          ? const StyleGuideScreen()
          : title != null
          ? SubPage(title: title(context.l10n))
          : const TodayScreen(),
    );
  }

  static final Map<String, Widget Function()> _sections = {
    AppRoutes.today: () => const TodayScreen(),
    AppRoutes.beans: () => const BeansScreen(),
    AppRoutes.brews: () => const BrewsScreen(),
    AppRoutes.equipment: () => const EquipmentScreen(),
    AppRoutes.more: () => const MoreScreen(),
    AppRoutes.water: () => const WaterScreen(),
    AppRoutes.care: () => const CareScreen(),
    AppRoutes.settings: () => const SettingsScreen(),
  };

  static final Map<String, Widget Function(String? id)> _pages = {
    AppRoutes.brewNew: (id) => BrewFormScreen(sourceBrewId: id),
    AppRoutes.brewDetail: (id) => BrewDetailScreen(brewId: id),
    AppRoutes.beanNew: (id) => const BeanFormScreen(),
    AppRoutes.beanEdit: (id) => BeanFormScreen(beanId: id),
    AppRoutes.beanDetail: (id) => BeanDetailScreen(beanId: id),
    AppRoutes.packNew: (id) => PackFormScreen(beanId: id),
    AppRoutes.packEdit: (id) => PackFormScreen(packId: id),
    AppRoutes.grinderNew: (id) => GrinderFormScreen(grinderId: id),
    AppRoutes.grinderEdit: (id) => GrinderFormScreen(grinderId: id),
    AppRoutes.machineNew: (id) => MachineFormScreen(machineId: id),
    AppRoutes.machineEdit: (id) => MachineFormScreen(machineId: id),
    AppRoutes.waterNew: (id) => WaterFormScreen(profileId: id),
    AppRoutes.waterEdit: (id) => WaterFormScreen(profileId: id),
    AppRoutes.waterDetail: (id) => WaterDetailScreen(profileId: id),
  };

  static final Map<String, String Function(AppLocalizations)> _subPageTitles = {
    AppRoutes.filter: (l) => l.filterGuided,
  };
}
