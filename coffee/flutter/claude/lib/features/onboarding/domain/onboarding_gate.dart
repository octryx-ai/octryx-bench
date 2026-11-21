import 'onboarding_flag.dart';

/// Decides whether the app starts with onboarding or with Heute.
class OnboardingGate {
  /// Creates a gate backed by [store].
  const OnboardingGate(this.store);

  /// The persistent flag store.
  final OnboardingFlagStore store;

  /// Whether onboarding is still needed.
  ///
  /// A missing or `false` flag means onboarding is needed. A read error counts
  /// as done, so the app never loops on onboarding. Never writes.
  Future<bool> isDone() async {
    try {
      final done = await store.read();
      return done ?? false;
    } on Object {
      return true;
    }
  }

  /// Marks onboarding as completed or skipped.
  ///
  /// Errors from the write are propagated unchanged to the caller.
  Future<void> markDone() => store.write(true);
}
