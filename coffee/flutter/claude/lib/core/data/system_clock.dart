import 'clock.dart';

/// [Clock] backed by the device time.
class SystemClock extends Clock {
  /// Creates a system clock.
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}
