import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/onboarding/data/shared_preferences_flag_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const store = SharedPreferencesFlagStore();

  test('key is onboardingDone', () {
    expect(SharedPreferencesFlagStore.key, 'onboardingDone');
  });

  test('read returns null when the flag is missing', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await store.read(), isNull);
  });

  test('read returns true when the flag is stored true', () async {
    SharedPreferences.setMockInitialValues({'onboardingDone': true});

    expect(await store.read(), isTrue);
  });

  test('read returns false when the flag is stored false', () async {
    SharedPreferences.setMockInitialValues({'onboardingDone': false});

    expect(await store.read(), isFalse);
  });

  test('write(true) then read gives true', () async {
    SharedPreferences.setMockInitialValues({});

    await store.write(true);

    expect(await store.read(), isTrue);
  });

  test(
    'a write that is not saved throws OnboardingFlagWriteException',
    () async {
      const refusing = SharedPreferencesFlagStore(setFlag: _refuse);

      await expectLater(
        refusing.write(true),
        throwsA(isA<OnboardingFlagWriteException>()),
      );
    },
  );
}

Future<bool> _refuse(bool done) async => false;
