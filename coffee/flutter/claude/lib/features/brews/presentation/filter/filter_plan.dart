import '../../../beans/domain/pack.dart';
import '../../../equipment/domain/grinder.dart';
import '../../domain/brew_method.dart';
import '../../domain/filter_recipe.dart';

/// What the setup phase decided: the inputs of the focus mode and the brew
/// that the finish phase saves.
class FilterPlan {
  /// Creates a plan.
  const FilterPlan({
    required this.method,
    required this.grinder,
    required this.pack,
    required this.grindSetting,
    required this.recipe,
    this.waterProfileId,
  });

  /// Filter method.
  final BrewMethod method;

  /// Grinder used.
  final Grinder grinder;

  /// Pack the coffee comes from.
  final Pack pack;

  /// Grinder dial setting.
  final double grindSetting;

  /// Recipe for the chosen dose and ratio.
  final FilterRecipe recipe;

  /// Water profile used, or null.
  final String? waterProfileId;
}
