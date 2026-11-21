import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_flag.dart';

/// The flag could not be saved; the page stays and offers a retry.
class OnboardingFlagWriteException implements Exception {
  /// Creates the exception for the preferences [key].
  const OnboardingFlagWriteException(this.key);

  /// Preferences key that was not saved.
  final String key;

  @override
  String toString() => 'OnboardingFlagWriteException: $key was not saved';
}

/// Stores the onboarding flag in `shared_preferences`. [setFlag] replaces the
/// platform write; tests use it to simulate a write that is not saved.
class SharedPreferencesFlagStore implements OnboardingFlagStore {
  /// Creates a store using the platform preferences.
  const SharedPreferencesFlagStore({this.setFlag});

  /// Replaces the platform write when set; tests use it to simulate a write
  /// that is not saved.
  final Future<bool> Function(bool done)? setFlag;

  /// Preferences key of the flag.
  static const String key = 'onboardingDone';

  @override
  Future<bool?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  @override
  Future<void> write(bool done) async {
    final saved = await (setFlag ?? _persist)(done);
    if (!saved) {
      throw OnboardingFlagWriteException(key);
    }
  }

  Future<bool> _persist(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, done);
  }
}
