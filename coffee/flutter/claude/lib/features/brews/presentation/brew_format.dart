import '../../../core/format/app_format.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/brew.dart';
import '../domain/brew_field_error.dart';
import '../domain/brew_method.dart';
import '../domain/taste.dart';

/// Localized labels and value texts of brews.
abstract final class BrewFormat {
  /// Label of a brew method.
  static String method(AppLocalizations l, BrewMethod m) => switch (m) {
    BrewMethod.espresso => l.methodEspresso,
    BrewMethod.v60 => l.methodV60,
    BrewMethod.chemex => l.methodChemex,
    BrewMethod.kalita => l.methodKalita,
    BrewMethod.aeropress => l.methodAeropress,
    BrewMethod.batch => l.methodBatch,
  };

  /// Label of a taste.
  static String taste(AppLocalizations l, Taste t) => switch (t) {
    Taste.sour => l.tasteSour,
    Taste.bitter => l.tasteBitter,
    Taste.weak => l.tasteWeak,
    Taste.balanced => l.tasteBalanced,
  };

  /// Grams for a stock message: no decimals if whole, else one decimal.
  static String stockGrams(double g) =>
      g == g.roundToDouble() ? AppFormat.plain(g) : g.toStringAsFixed(1);

  /// Grind setting with one decimal (`12.0`, `11.5`); finer scales such as
  /// 0.25 steps keep their exact value.
  static String setting(double v) {
    final tenths = v * 10;
    return (tenths - tenths.roundToDouble()).abs() < 1e-9
        ? v.toStringAsFixed(1)
        : AppFormat.plain(v);
  }

  /// Seconds as `27 s`.
  static String seconds(AppLocalizations l, int s) =>
      l.secondsValue(s.toString());

  /// Shot time of [brew] as `27 s`, or `-` without one.
  static String time(AppLocalizations l, Brew brew) {
    final s = brew.shotTimeS;
    return s == null ? '–' : seconds(l, s);
  }

  /// Rating as `★ 4`.
  static String rating(int rating) => '★ $rating';

  /// Ratio yield to dose as `1:2.0`, or `-` without a yield.
  static String ratio(Brew brew) {
    final y = brew.yieldG;
    return y == null ? '–' : '1:${(y / brew.doseG).toStringAsFixed(1)}';
  }

  /// Local clock time as `07:05`.
  static String clock(DateTime local) =>
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';

  /// Elapsed [seconds] as `m:ss`.
  static String minutes(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  /// Error line of a form field; [dose] bounds the yield range.
  static String error(
    AppLocalizations l,
    BrewFieldError error, {
    double? dose,
  }) => switch (error) {
    BrewFieldError.doseRequired ||
    BrewFieldError.doseOutOfRange => l.rangeError('5', '40'),
    BrewFieldError.yieldRequired || BrewFieldError.yieldOutOfRange =>
      dose == null
          ? l.rangeError('1', '4')
          : l.rangeError(AppFormat.plain(dose), AppFormat.plain(4 * dose)),
    BrewFieldError.shotTimeRequired ||
    BrewFieldError.shotTimeOutOfRange => l.rangeError('1', '120'),
    BrewFieldError.ratingOutOfRange => l.rangeError('1', '5'),
    BrewFieldError.purgeOutOfRange => l.rangeError('0', '50'),
    // The grind setting error needs the grinder's scale; the form builds it.
    BrewFieldError.grindRequired => '',
  };
}
