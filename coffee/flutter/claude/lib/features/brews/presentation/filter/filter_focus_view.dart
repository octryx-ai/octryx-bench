import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/format/app_format.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/focus_tokens.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/filter_recipe.dart';
import '../../domain/filter_step.dart';
import '../brew_format.dart';
import 'step_feedback.dart';

/// Focus mode of the guided filter: full screen, no navigation, one recipe
/// step per view with the running timer and the pour target.
///
/// The timer starts with the view. At the end of a step (the planned time of
/// the next step; for the last step the lower target time) [feedback] fires
/// once. "Next" moves on; after the last step [onFinished] gets the elapsed
/// whole seconds.
class FilterFocusView extends StatefulWidget {
  /// Creates the view for [recipe].
  const FilterFocusView({
    required this.recipe,
    required this.feedback,
    required this.onFinished,
    required this.onCancel,
    super.key,
  });

  /// Recipe whose steps are shown.
  final FilterRecipe recipe;

  /// Cue at the end of a step.
  final StepFeedback feedback;

  /// Called with the elapsed seconds after the last step.
  final ValueChanged<int> onFinished;

  /// Called when the user cancels.
  final VoidCallback onCancel;

  @override
  State<FilterFocusView> createState() => _FilterFocusViewState();
}

class _FilterFocusViewState extends State<FilterFocusView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  Timer? _flashTimer;
  Duration _elapsed = Duration.zero;
  int _step = 0;
  int _fired = -1;
  bool _flash = false;

  List<FilterStep> get _steps => widget.recipe.steps;

  /// Second at which the current step ends.
  int get _endS => _step + 1 < _steps.length
      ? _steps[_step + 1].atS
      : widget.recipe.targetMinS;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final before = _elapsed.inSeconds;
    _elapsed = elapsed;
    if (elapsed.inSeconds != before) setState(() {});
    if (_fired < _step && elapsed.inSeconds >= _endS) {
      _fired = _step;
      widget.feedback.fire();
      if (widget.feedback.flashes) _startFlash();
    }
  }

  void _startFlash() {
    _flashTimer?.cancel();
    setState(() => _flash = true);
    _flashTimer = Timer(FocusTokens.flashDuration, () {
      if (mounted) setState(() => _flash = false);
    });
  }

  void _next() {
    if (_step + 1 < _steps.length) {
      setState(() => _step++);
      return;
    }
    _ticker.stop();
    widget.onFinished(
      (_elapsed.inMilliseconds / Duration.millisecondsPerSecond).round(),
    );
  }

  String _name(BuildContext context) => _step == 0
      ? context.l10n.filterStepBloom
      : context.l10n.filterStepPour('$_step');

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final step = _steps[_step];
    final time = BrewFormat.timer(_elapsed.inSeconds);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: Tokens.contentMaxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Tokens.space24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _name(context),
                              key: const Key('focus-step-name'),
                              style: text.headlineMedium,
                            ),
                            Text(
                              l.filterAtTime(BrewFormat.minutes(step.atS)),
                              key: const Key('focus-step-time'),
                              style: text.bodyLarge,
                            ),
                            const SizedBox(height: Tokens.space24),
                            Semantics(
                              label: l.filterTimerLabel(time),
                              excludeSemantics: true,
                              child: Text(
                                time,
                                key: const Key('focus-timer'),
                                style: text.displayLarge!.copyWith(
                                  fontSize: FocusTokens.timerFontSize,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: Tokens.space16),
                            Text(
                              l.filterPourTo(AppFormat.plain(step.cumulativeG)),
                              key: const Key('focus-target'),
                              textAlign: TextAlign.center,
                              style: text.displayMedium!.copyWith(
                                fontSize: FocusTokens.targetFontSize,
                                color: c.accent,
                              ),
                            ),
                            const SizedBox(height: Tokens.space48),
                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                key: const Key('focus-next'),
                                label: l.filterNext,
                                onPressed: _next,
                              ),
                            ),
                            const SizedBox(height: Tokens.space12),
                            TextButton(
                              key: const Key('focus-cancel'),
                              onPressed: widget.onCancel,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(
                                  Tokens.touchTarget,
                                  Tokens.touchTarget,
                                ),
                                foregroundColor: c.accent,
                              ),
                              child: Text(l.cancel),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_flash)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    key: const Key('step-flash'),
                    color: c.accent.withValues(alpha: FocusTokens.flashAlpha),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
