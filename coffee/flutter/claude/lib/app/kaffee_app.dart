import 'package:material_ui/material_ui.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'app_router.dart';
import 'app_routes.dart';

/// Root widget: themes from tokens (system brightness), German and English
/// localizations with English as fallback, and the named-route navigator.
class KaffeeApp extends StatelessWidget {
  /// Creates the app.
  const KaffeeApp({super.key});

  /// Any German locale resolves to `de`, everything else to `en`.
  static Locale resolveLocale(Locale? locale, Iterable<Locale> supported) =>
      locale?.languageCode == 'de' ? const Locale('de') : const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: resolveLocale,
      initialRoute: AppRoutes.today,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
