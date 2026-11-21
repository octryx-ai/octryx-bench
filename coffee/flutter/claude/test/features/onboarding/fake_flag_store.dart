import 'package:kaffee_begleiter/features/onboarding/domain/onboarding_flag.dart';

/// In-memory onboarding flag store for widget tests.
///
/// [value] is what [read] returns (null: never written). [readError] makes
/// every read throw. The first [writeFailures] writes throw and leave the
/// value unchanged, so a retry can succeed.
class FakeFlagStore implements OnboardingFlagStore {
  /// Creates a store; the default is a flag that is already done.
  FakeFlagStore({
    this.value = true,
    this.readError,
    this.writeFailures = 0,
    this.writeError,
  });

  /// Current flag value; null means the flag was never written.
  bool? value;

  /// Error thrown by every read, or null.
  final Object? readError;

  /// Number of upcoming writes that fail.
  int writeFailures;

  /// Error thrown by every write, or null.
  final Object? writeError;

  /// Number of write calls, failed ones included.
  int writeCount = 0;

  @override
  Future<bool?> read() async {
    final error = readError;
    if (error != null) throw error;
    return value;
  }

  @override
  Future<void> write(bool done) async {
    writeCount++;
    final error = writeError;
    if (error != null) throw error;
    if (writeFailures > 0) {
      writeFailures--;
      throw StateError('write failed');
    }
    value = done;
  }
}
