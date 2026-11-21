import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/onboarding/domain/onboarding_gate.dart';

import 'fake_flag_store.dart';

void _isDoneTests() {
  group('OnboardingGate.isDone', () {
    test('neu: missing flag means onboarding is needed', () async {
      final gate = OnboardingGate(FakeFlagStore(value: null));

      expect(await gate.isDone(), isFalse);
    });

    test('neu: stored false means onboarding is needed', () async {
      final gate = OnboardingGate(FakeFlagStore(value: false));

      expect(await gate.isDone(), isFalse);
    });

    test('erledigt: stored true means done', () async {
      final gate = OnboardingGate(FakeFlagStore(value: true));

      expect(await gate.isDone(), isTrue);
    });

    test('Lesefehler: read error counts as done without rethrow', () async {
      final gate = OnboardingGate(FakeFlagStore(readError: StateError('disk')));

      expect(await gate.isDone(), isTrue);
    });

    test('isDone never writes the flag', () async {
      final store = FakeFlagStore(value: null);
      final gate = OnboardingGate(store);

      await gate.isDone();
      await gate.isDone();

      expect(store.writeCount, 0);
      expect(store.value, isNull);
    });
  });
}

void _markDoneTests() {
  group('OnboardingGate.markDone', () {
    test('uebersprungen: after markDone a new check is done', () async {
      final store = FakeFlagStore(value: null);
      final gate = OnboardingGate(store);

      await gate.markDone();

      expect(store.value, isTrue);
      expect(await OnboardingGate(store).isDone(), isTrue);
    });

    test(
      'Schreibfehler: error propagates and stored value stays false',
      () async {
        final error = StateError('write failed');
        final store = FakeFlagStore(value: false, writeError: error);
        final gate = OnboardingGate(store);

        await expectLater(gate.markDone(), throwsA(same(error)));
        expect(store.value, isFalse);
      },
    );

    test('Schreibfehler: missing flag stays missing', () async {
      final store = FakeFlagStore(
        value: null,
        writeError: StateError('write failed'),
      );
      final gate = OnboardingGate(store);

      await expectLater(gate.markDone(), throwsStateError);
      expect(store.value, isNull);
    });
  });
}

void main() {
  _isDoneTests();
  _markDoneTests();
}
