import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Cue at the end of a filter step: on Android and iOS a medium haptic impact
/// and the alert system sound; on the web only the visual flash, which the
/// focus view draws when [flashes] is true.
class StepFeedback {
  /// Creates the feedback; [web] defaults to the running platform.
  const StepFeedback({bool? web}) : web = web ?? kIsWeb;

  /// Whether the app runs in a browser (no haptics, no sound).
  final bool web;

  /// Whether the focus view shows the flash.
  bool get flashes => web;

  /// Plays the haptic and sound cue; does nothing on the web.
  Future<void> fire() async {
    if (web) return;
    await HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.alert);
  }
}
