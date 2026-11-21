import '../features/beans/domain/bean.dart';
import '../features/beans/domain/pack.dart';
import '../features/beans/domain/rest_method.dart';
import '../features/brews/domain/brew.dart';
import '../features/brews/domain/filter_advisor.dart';
import '../features/brews/domain/filter_pack_suggester.dart';
import '../features/brews/domain/filter_recipe_calculator.dart';
import '../features/brews/domain/pack_suggestion.dart';
import '../features/brews/domain/recommendation.dart';
import 'app_data_brews.dart';

/// Filter part of `AppData`: recipes, pack suggestions and the advice
/// dispatch between espresso and filter.
mixin AppDataFilter on AppDataBrews {
  /// Live beans.
  List<Bean> get beans;

  /// Live packs.
  List<Pack> get packs;

  /// Filter recipe calculator (SPEC R10).
  late final FilterRecipeCalculator filterRecipes = FilterRecipeCalculator(
    brewRules,
  );

  /// Filter dial-in advisor (SPEC R11).
  late final FilterAdvisor filterAdvisor = FilterAdvisor(brewRules);

  /// Packs fit for a filter brew today (SPEC R3).
  List<PackSuggestion> filterPackSuggestions() => FilterPackSuggester(rest)
      .suggest(
        packs: packs,
        beansById: {for (final b in beans) b.id: b},
        today: today,
      );

  /// Next dial-in step for [brew]; its grinder, pack and bean must exist.
  ///
  /// Espresso brews use [advisor]; filter brews use [filterAdvisor] with the
  /// filter rest time.
  Recommendation recommendFor(Brew brew) {
    final pack = packById(brew.packId)!;
    final bean = beanById(pack.beanId)!;
    final waterId =
        brew.waterProfileId ??
        (brew.machineId == null
            ? null
            : machineById(brew.machineId!)?.defaultWaterProfileId);
    final water = waterId == null ? null : waterProfileById(waterId);
    final assessment = water == null ? null : checker.assess(water);
    final grinder = grinderById(brew.grinderId)!;
    if (brew.method.isFilter) {
      return filterAdvisor.advise(
        brew: brew,
        grinder: grinder,
        water: water,
        assessment: assessment,
        readiness: rest.readiness(pack, bean, today, method: RestMethod.filter),
      );
    }
    return advisor.advise(
      brew: brew,
      grinder: grinder,
      water: water,
      assessment: assessment,
      readiness: rest.readiness(pack, bean, today),
    );
  }
}
