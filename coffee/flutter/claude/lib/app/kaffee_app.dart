import 'package:material_ui/material_ui.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'app_data.dart';
import 'app_services.dart';
import 'app_scope.dart';
import 'app_router.dart';
import 'app_routes.dart';

/// Root widget: themes from tokens (system brightness), German and English
/// localizations with English as fallback, and the named-route navigator.
class KaffeeApp extends StatefulWidget {
  /// Creates the app with [data] (default: empty in-memory state).
  const KaffeeApp({super.key, this.data, this.services});

  /// Application state; created internally if null.
  final AppData? data;

  /// Platform services; the browser or device defaults if null.
  final AppServices? services;

  /// Any German locale resolves to `de`, everything else to `en`.
  static Locale resolveLocale(Locale? locale, Iterable<Locale> supported) =>
      locale?.languageCode == 'de' ? const Locale('de') : const Locale('en');

  @override
  State<KaffeeApp> createState() => _KaffeeAppState();
}

class _KaffeeAppState extends State<KaffeeApp> {
  late final AppData _data = widget.data ?? AppData();
  late final AppServices _services = widget.services ?? AppServices();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      data: _data,
      child: AppServicesScope(
        services: _services,
        child: MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          localizationsDelegates: [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: KaffeeApp.resolveLocale,
          initialRoute: AppRoutes.today,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
