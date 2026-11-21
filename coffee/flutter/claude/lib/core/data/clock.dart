/// Source of the current time; replaceable in tests.
abstract class Clock {
  /// Creates a clock.
  const Clock();

  /// The current instant as a UTC [DateTime].
  DateTime now();
}
