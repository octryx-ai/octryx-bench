import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_field.dart';
import 'brew_format.dart';

/// Shot time field with a Start/Stop timer. While running, the elapsed whole
/// seconds are written into the field every second; stopping rounds to the
/// nearest second. The field stays editable by hand at any time.
class ShotTimerField extends StatefulWidget {
  /// Creates the field around [controller].
  const ShotTimerField({required this.controller, this.errorText, super.key});

  /// Holds the shot time in seconds.
  final TextEditingController controller;

  /// Error line under the field.
  final String? errorText;

  @override
  State<ShotTimerField> createState() => _ShotTimerFieldState();
}

class _ShotTimerFieldState extends State<ShotTimerField>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  int _seconds = 0;
  Duration _elapsed = Duration.zero;

  bool get _running => _ticker.isActive;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _elapsed = elapsed;
    final whole = elapsed.inSeconds;
    if (whole == _seconds) return;
    setState(() => _seconds = whole);
    widget.controller.text = '$whole';
  }

  void _toggle() {
    if (_running) {
      _ticker.stop();
      final rounded = (_elapsed.inMilliseconds / Duration.millisecondsPerSecond)
          .round();
      setState(() => _seconds = rounded);
      if (rounded > 0) widget.controller.text = '$rounded';
    } else {
      _elapsed = Duration.zero;
      setState(() => _seconds = 0);
      _ticker.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final shown = BrewFormat.minutes(_seconds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppField(
          key: const Key('field-shot'),
          label: l.brewShotTime,
          controller: widget.controller,
          unit: l.unitS,
          keyboardType: TextInputType.number,
          errorText: widget.errorText,
        ),
        const SizedBox(height: Tokens.space8),
        Row(
          children: [
            Semantics(
              container: true,
              label: l.timerElapsed(shown),
              excludeSemantics: true,
              child: Text(
                shown,
                key: const Key('timer-elapsed'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Spacer(),
            OutlinedButton(
              key: const Key('timer-toggle'),
              onPressed: _toggle,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(Tokens.touchTarget, Tokens.touchTarget),
                foregroundColor: c.accent,
                side: BorderSide(color: c.accent),
              ),
              child: Text(_running ? l.timerStop : l.timerStart),
            ),
          ],
        ),
      ],
    );
  }
}
