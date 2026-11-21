import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Shortcut to the generated localizations.
extension L10nContext on BuildContext {
  /// Localized strings of the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
