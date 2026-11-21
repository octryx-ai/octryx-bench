/// Persistent store of the onboarding flag `onboardingDone`.
abstract interface class OnboardingFlagStore {
  /// Reads the flag; returns `null` when it has never been written.
  ///
  /// May throw when the underlying storage cannot be read.
  Future<bool?> read();

  /// Writes the flag; throws when the value could not be persisted.
  Future<void> write(bool done);
}
