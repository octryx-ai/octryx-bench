import 'clock.dart';

/// Controllable [Clock] for tests.
class FixedClock extends Clock {
  /// Creates a clock that starts at [start] (converted to UTC).
  FixedClock(DateTime start) : _now = start.toUtc();

  DateTime _now;

  @override
  DateTime now() => _now;

  /// Moves the clock forward by [by].
  void advance(Duration by) => _now = _now.add(by);

  /// Sets the clock to [value] (converted to UTC).
  void set(DateTime value) => _now = value.toUtc();
}
