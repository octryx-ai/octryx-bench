import '../../l10n/app_localizations.dart';

/// Maximum length of a record name (SPEC section 5).
const int maxNameLength = 60;

/// Error text for a name field, or null if [text] is 1 to 60 characters
/// after trimming.
String? nameError(AppLocalizations l, String text) {
  final name = text.trim();
  if (name.isEmpty) return l.nameRequired;
  if (name.length > maxNameLength) return l.tooLong(maxNameLength);
  return null;
}
