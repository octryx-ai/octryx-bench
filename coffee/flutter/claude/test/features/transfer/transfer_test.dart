import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/settings/domain/hardness_unit.dart';
import 'package:kaffee_begleiter/features/transfer/domain/import_error.dart';
import 'package:kaffee_begleiter/features/transfer/domain/import_exception.dart';

import '../../core/test_app_data.dart';
import '../brews/brew_test_helpers.dart';

Map<String, Object?> decode(String json) =>
    (jsonDecode(json) as Map).cast<String, Object?>();

void main() {
  test('export has schema version 1, all lists and the file name', () async {
    final s = await seedBrewData();
    await s.brew();
    final root = decode(s.data.exportJson());
    expect(root['schemaVersion'], 1);
    for (final key in [
      'grinders',
      'machines',
      'waterProfiles',
      'beans',
      'packs',
      'brews',
      'careEvents',
    ]) {
      expect(root[key], isA<List<Object?>>(), reason: key);
    }
    expect((root['beans']! as List).single, containsPair('name', 'Kenya AA'));
    expect(root['settings'], containsPair('hardnessUnit', 'fH'));
    expect(s.data.exportFileName, 'coffee-export-2026-11-16.json');
  });

  test('UC9: export, delete all data, import restores the data', () async {
    final s = await seedBrewData();
    await s.brew();
    final json = s.data.exportJson();
    await s.data.clearAll();
    expect(s.data.beans, isEmpty);
    expect(s.data.brews, isEmpty);
    final result = await s.data.importJson(json);
    expect(result.skipped, 0);
    expect(s.data.beans.single.name, 'Kenya AA');
    expect(s.data.packs, hasLength(1));
    expect(s.data.brews, hasLength(1));
    expect(s.data.grinders.single.name, 'M1');
  });

  test('export includes soft-deleted records with deletedAt', () async {
    final s = await seedBrewData();
    await s.data.deleteGrinder(s.grinder.id);
    final grinders = decode(s.data.exportJson())['grinders']! as List;
    expect(grinders.single, containsPair('id', s.grinder.id));
    expect((grinders.single as Map)['deletedAt'], isNotNull);
  });

  test('a newer updatedAt wins, an older one is unchanged', () async {
    final s = await seedBrewData();
    final root = decode(s.data.exportJson());
    final bean = Map<String, Object?>.from(
      (root['beans']! as List).single as Map,
    );
    final updated = DateTime.parse(bean['updatedAt']! as String);
    bean['name'] = 'Newer';
    bean['updatedAt'] = updated.add(const Duration(hours: 1)).toIso8601String();
    root['beans'] = [bean];
    final newer = await s.data.importJson(jsonEncode(root));
    expect(newer.imported, 1);
    expect(s.data.beans.single.name, 'Newer');

    bean['name'] = 'Older';
    bean['updatedAt'] = updated
        .subtract(const Duration(hours: 1))
        .toIso8601String();
    final older = await s.data.importJson(jsonEncode(root));
    expect(older.imported, 0);
    expect(older.unchanged, greaterThan(0));
    expect(s.data.beans.single.name, 'Newer');
  });

  test('a newer deletedAt deletes the local record', () async {
    final s = await seedBrewData();
    final root = decode(s.data.exportJson());
    final grinder = Map<String, Object?>.from(
      (root['grinders']! as List).single as Map,
    );
    final later = DateTime.parse(grinder['updatedAt']! as String)
        .add(const Duration(hours: 2))
        .toIso8601String();
    grinder['deletedAt'] = later;
    grinder['updatedAt'] = later;
    root['grinders'] = [grinder];
    final result = await s.data.importJson(jsonEncode(root));
    expect(result.deletedApplied, 1);
    expect(s.data.grinders, isEmpty);
    expect(s.data.grinderById(s.grinder.id), isNotNull);
  });

  test('records with a missing reference are skipped and counted', () async {
    final s = await seedBrewData();
    final json = s.data.exportJson();
    await s.data.clearAll();
    final root = decode(json);
    root['beans'] = <Object?>[];
    final result = await s.data.importJson(jsonEncode(root));
    expect(result.skipped, 1);
    expect(s.data.packs, isEmpty);
    expect(s.data.beans, isEmpty);
  });

  test('unknown schemaVersion is rejected and changes nothing', () async {
    final s = await seedBrewData();
    final root = decode(s.data.exportJson())..['schemaVersion'] = 2;
    await expectLater(
      s.data.importJson(jsonEncode(root)),
      throwsA(
        isA<ImportException>().having(
          (e) => e.error,
          'error',
          ImportError.unsupportedVersion,
        ),
      ),
    );
    expect(s.data.beans, hasLength(1));
  });

  test('invalid or broken files are rejected without any change', () async {
    final s = await seedBrewData();
    await expectLater(
      s.data.importJson('not json'),
      throwsA(isA<ImportException>()),
    );
    final root = decode(s.data.exportJson());
    final bean = Map<String, Object?>.from(
      (root['beans']! as List).single as Map,
    );
    bean['id'] = 'new-bean';
    bean['name'] = 'Half imported';
    root['beans'] = [
      bean,
      {'id': 'broken'},
    ];
    await expectLater(
      s.data.importJson(jsonEncode(root)),
      throwsA(isA<ImportException>()),
    );
    expect(s.data.beans.single.name, 'Kenya AA');
  });

  test('the hardness unit setting travels with the file', () async {
    final s = await seedBrewData();
    await s.data.setHardnessUnit(HardnessUnit.dH);
    final json = s.data.exportJson();
    final fresh = await loadTestAppData();
    await fresh.importJson(json);
    expect(fresh.hardnessUnit, HardnessUnit.dH);
  });
}
