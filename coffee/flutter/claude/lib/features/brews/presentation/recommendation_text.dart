import '../../../l10n/app_localizations.dart';
import '../../water/domain/water_checker.dart';
import '../../water/presentation/water_format.dart';
import '../domain/brew.dart';
import '../domain/recommendation.dart';
import 'brew_format.dart';

/// The one-sentence advice and the reason sentence of a [Recommendation].
abstract final class RecommendationText {
  /// The single sentence, e.g. `Set grind to 11.5` or `No change`.
  static String sentence(
    AppLocalizations l,
    Recommendation r,
    WaterChecker checker,
  ) {
    final setting = r.newSetting ?? r.currentSetting;
    final parameter = r.waterParameter;
    final value = r.waterValue;
    return switch (r.reason) {
      ReasonCode.noWater => l.recNoWater,
      ReasonCode.waterOutside =>
        parameter == null || value == null
            ? l.recNoWater
            : l.waterCheckFirst(
                WaterFormat.inlineLabel(l, parameter),
                WaterFormat.value(l, parameter, value),
                WaterFormat.range(l, parameter, checker.rangeOf(parameter)),
              ),
      ReasonCode.packResting => l.recRest(r.restDaysLeft ?? 0),
      ReasonCode.balancedInWindow => l.recNoChange,
      ReasonCode.scaleEnd => l.recScaleEnd(
        BrewFormat.setting(r.currentSetting ?? setting ?? 0),
      ),
      _ =>
        r.newSetting == null
            ? l.recNoChange
            : l.recGrind(BrewFormat.setting(r.newSetting!)),
    };
  }

  /// Why the advice was given, including the step amount of a grind change.
  static String reason(AppLocalizations l, Recommendation r, Brew brew) =>
      switch (r.reason) {
        ReasonCode.noWater => l.reasonNoWater,
        ReasonCode.waterOutside => l.reasonWaterOutside,
        ReasonCode.packResting => l.reasonPackResting,
        ReasonCode.timeTooShort => l.reasonTimeTooShort(
          (brew.shotTimeS ?? 0).toString(),
          r.steps,
        ),
        ReasonCode.timeTooLong => l.reasonTimeTooLong(
          (brew.shotTimeS ?? 0).toString(),
          r.steps,
        ),
        ReasonCode.tasteSour => l.reasonTasteSour(r.steps),
        ReasonCode.tasteWeak => l.reasonTasteWeak(r.steps),
        ReasonCode.tasteBitter => l.reasonTasteBitter(r.steps),
        ReasonCode.balancedInWindow => l.reasonBalanced,
        ReasonCode.scaleEnd => l.reasonScaleEnd,
      };
}
