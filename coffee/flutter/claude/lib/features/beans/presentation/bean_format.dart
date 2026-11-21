import '../../../core/format/app_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/bean_field_error.dart';
import '../domain/bean_kind.dart';
import '../domain/roast_level.dart';

/// Localized labels for bean values and validation errors.
abstract final class BeanFormat {
  /// Label of a roast level.
  static String roast(AppLocalizations l, RoastLevel level) => switch (level) {
    RoastLevel.light => l.roastLight,
    RoastLevel.medium => l.roastMedium,
    RoastLevel.mediumDark => l.roastMediumDark,
    RoastLevel.dark => l.roastDark,
  };

  /// Label of a bean kind.
  static String kind(AppLocalizations l, BeanKind kind) => switch (kind) {
    BeanKind.espressoBlend => l.kindEspressoBlend,
    BeanKind.filter => l.kindFilter,
    BeanKind.allround => l.kindAllround,
  };

  /// Grams as `250 g`.
  static String grams(AppLocalizations l, double g) =>
      l.gramsValue(AppFormat.plain(g));

  /// Error line for a validation [error].
  static String error(AppLocalizations l, BeanFieldError error) =>
      switch (error) {
        BeanFieldError.nameRequired => l.nameRequired,
        BeanFieldError.nameTooLong => l.tooLong(60),
        BeanFieldError.sizeRequired ||
        BeanFieldError.sizeOutOfRange => l.rangeError('50', '5000'),
        BeanFieldError.leadTimeRequired ||
        BeanFieldError.leadTimeOutOfRange => l.rangeError('0', '60'),
        BeanFieldError.minStockOutOfRange => l.rangeError('0', '5000'),
        BeanFieldError.roastDateRequired => l.dateRequired,
        BeanFieldError.roastDateInFuture => l.dateFuture,
      };
}
