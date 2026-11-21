import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/brews/presentation/brew_form_input.dart';
import 'package:kaffee_begleiter/l10n/app_localizations_en.dart';

import 'brew_test_helpers.dart';

void main() {
  final l = AppLocalizationsEn();

  Future<BrewFormInput> input({
    required String dose,
    required String yieldG,
  }) async {
    final s = await seedBrewData();
    return BrewFormInput(
      grinder: s.grinder,
      grind: '12',
      dose: dose,
      yieldG: yieldG,
      purge: '',
      shot: '27',
    );
  }

  test(
    'dose out of range is reported even when the yield looks valid',
    () async {
      final errors = (await input(dose: '50', yieldG: '60')).errors(l);
      expect(errors['dose'], 'Enter a value between 5 and 40');
      expect(errors.containsKey('yield'), isFalse);
    },
  );

  test('missing dose reports the dose error before any yield error', () async {
    final errors = (await input(dose: '', yieldG: '36')).errors(l);
    expect(errors.containsKey('dose'), isTrue);
    expect(errors.containsKey('yield'), isFalse);
  });

  test('valid dose and yield produce no errors', () async {
    expect((await input(dose: '18', yieldG: '36')).errors(l), isEmpty);
  });
}
