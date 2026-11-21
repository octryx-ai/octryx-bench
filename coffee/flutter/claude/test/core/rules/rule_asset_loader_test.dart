import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/rules/rule_asset_loader.dart';
import 'package:kaffee_begleiter/core/rules/rule_set.dart';
import 'package:kaffee_begleiter/core/rules/rule_source.dart';

class _MapSource implements RuleSource {
  _MapSource(this.files);
  final Map<String, String> files;

  @override
  Future<String> loadString(String assetName) async => files[assetName]!;
}

class _DiskSource implements RuleSource {
  @override
  Future<String> loadString(String assetName) => File(assetName).readAsString();
}

RuleAssetLoader _loader(String json) =>
    RuleAssetLoader(_MapSource({'a.json': json}));

void main() {
  test('parses entries', () async {
    final entries = await _loader(
      '{"version":1,"rules":[{"key":"k","value":5,'
      '"source":"https://x.test","retrieved":"2026-11-16"}]}',
    ).load('a.json');
    expect(entries, hasLength(1));
    expect(entries.single.key, 'k');
    expect(entries.single.value, 5);
    expect(entries.single.retrieved, '2026-11-16');
    expect(entries.single.hasSource, isTrue);
  });

  test('source none reports hasSource false', () async {
    final entries = await _loader(
      '{"version":1,"rules":[{"key":"k","value":1,'
      '"source":"none","retrieved":"2026-11-16"}]}',
    ).load('a.json');
    expect(entries.single.hasSource, isFalse);
  });

  for (final bad in [
    '{"version":1,"rules":[{"value":1,"source":"none","retrieved":"d"}]}',
    '{"version":1,"rules":[{"key":"k","value":1,"retrieved":"d"}]}',
    '{"version":1,"rules":[{"key":"k","value":1,"source":"none"}]}',
    '{"version":2,"rules":[]}',
    '{"version":1}',
    'not json',
  ]) {
    test('invalid input throws FormatException: $bad', () {
      expect(_loader(bad).load('a.json'), throwsFormatException);
    });
  }

  test('RuleSet looks up entries', () async {
    final set = RuleSet(
      await _loader(
        '{"version":1,"rules":[{"key":"k","value":5,'
        '"source":"none","retrieved":"d"}]}',
      ).load('a.json'),
    );
    expect(set.entry('k').value, 5);
    expect(set.number('k'), 5);
    expect(set.maybeEntry('x'), isNull);
    expect(() => set.entry('x'), throwsArgumentError);
  });

  test('real asset files parse and have keys', () async {
    final loader = RuleAssetLoader(_DiskSource());
    for (final name in [
      'water_rules.json',
      'rest_rules.json',
      'care_rules.json',
      'brew_rules.json',
    ]) {
      final set = await loader.loadSet('assets/$name');
      expect(set.entries, isNotEmpty, reason: name);
      for (final e in set.entries) {
        expect(e.key, isNotEmpty);
        expect(e.retrieved, '2026-11-16');
      }
    }
    final rest = await loader.loadSet('assets/rest_rules.json');
    expect(rest.number('rest.espresso.medium'), 10);
    final care = await loader.loadSet('assets/care_rules.json');
    expect(care.entry('grinderClean.days').hasSource, isFalse);
    expect(care.entry('backflush.days').hasSource, isTrue);
  });
}
