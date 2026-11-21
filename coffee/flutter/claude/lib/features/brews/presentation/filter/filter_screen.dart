import 'package:material_ui/material_ui.dart';

import 'filter_finish_view.dart';
import 'filter_focus_view.dart';
import 'filter_plan.dart';
import 'filter_setup_view.dart';
import 'step_feedback.dart';

/// Guided filter: setup, then the focus mode with one recipe step per view,
/// then the finish page that saves the brew. [sourceBrewId] prefills the
/// setup ("Next try").
class FilterScreen extends StatefulWidget {
  /// Creates the screen; tests pass their own [feedback].
  const FilterScreen({
    this.sourceBrewId,
    this.feedback = const StepFeedback(),
    super.key,
  });

  /// Brew whose values prefill the setup, or null.
  final String? sourceBrewId;

  /// Cue at the end of a step.
  final StepFeedback feedback;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  FilterPlan? _plan;
  int? _elapsedS;

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    if (plan == null) {
      return FilterSetupView(
        sourceBrewId: widget.sourceBrewId,
        onStart: (p) => setState(() => _plan = p),
      );
    }
    final elapsed = _elapsedS;
    if (elapsed == null) {
      return FilterFocusView(
        recipe: plan.recipe,
        feedback: widget.feedback,
        onFinished: (s) => setState(() => _elapsedS = s),
        onCancel: () => Navigator.of(context).maybePop(),
      );
    }
    return FilterFinishView(plan: plan, elapsedS: elapsed);
  }
}
