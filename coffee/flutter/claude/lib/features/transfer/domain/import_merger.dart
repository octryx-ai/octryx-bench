import 'dart:convert';

import '../../../core/data/base_record.dart';
import '../../beans/domain/bean.dart';
import '../../beans/domain/pack.dart';
import '../../brews/domain/brew.dart';
import '../../care/domain/care_event.dart';
import '../../equipment/domain/grinder.dart';
import '../../equipment/domain/machine.dart';
import '../../settings/data/app_settings.dart';
import '../../settings/domain/hardness_unit.dart';
import '../../water/domain/water_profile.dart';
import 'data_snapshot.dart';
import 'export_codec.dart';
import 'import_error.dart';
import 'import_exception.dart';
import 'import_outcome.dart';
import 'import_result.dart';
import 'merge_step.dart';

/// Merges an export file into existing data without touching anything.
///
/// Pure computation on copies: the caller commits the returned snapshot in
/// one go, so an error here leaves all data unchanged.
class ImportMerger {
  /// Creates a merger.
  const ImportMerger();

  /// Merges [json] into [local]; throws [ImportException] if the file is
  /// unusable (invalid JSON, unsupported `schemaVersion`, missing arrays or
  /// a record that cannot be read).
  ImportOutcome merge(DataSnapshot local, String json) {
    final Map<String, Object?> root;
    try {
      root = (jsonDecode(json) as Map).cast<String, Object?>();
    } catch (_) {
      throw const ImportException(ImportError.invalidFile);
    }
    final version = root['schemaVersion'];
    if (version is! num) throw const ImportException(ImportError.invalidFile);
    if (version != ExportCodec.schemaVersion) {
      throw const ImportException(ImportError.unsupportedVersion);
    }
    try {
      return _merge(local, root);
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException(ImportError.invalidFile);
    }
  }

  List<T> _read<T extends BaseRecord>(
    Map<String, Object?> root,
    String key,
    T Function(Map<String, Object?>) parse,
  ) => [
    for (final e in root[key]! as List<Object?>)
      parse((e! as Map).cast<String, Object?>()),
  ];

  ImportOutcome _merge(DataSnapshot local, Map<String, Object?> root) {
    final waters = MergeStep.run(
      local.waterProfiles,
      _read(root, 'waterProfiles', WaterProfile.fromJson),
      (_) => true,
    );
    final waterIds = waters.ids;
    final grinders = MergeStep.run(
      local.grinders,
      _read(root, 'grinders', Grinder.fromJson),
      (_) => true,
    );
    final grinderIds = grinders.ids;
    final machines = MergeStep.run(
      local.machines,
      _read(root, 'machines', Machine.fromJson),
      (m) => _has(waterIds, m.defaultWaterProfileId),
    );
    final machineIds = machines.ids;
    final beans = MergeStep.run(
      local.beans,
      _read(root, 'beans', Bean.fromJson),
      (_) => true,
    );
    final beanIds = beans.ids;
    final packs = MergeStep.run(
      local.packs,
      _read(root, 'packs', Pack.fromJson),
      (p) => beanIds.contains(p.beanId),
    );
    final packIds = packs.ids;
    final brews = MergeStep.run(
      local.brews,
      _read(root, 'brews', Brew.fromJson),
      (b) =>
          grinderIds.contains(b.grinderId) &&
          packIds.contains(b.packId) &&
          _has(machineIds, b.machineId) &&
          _has(waterIds, b.waterProfileId),
    );
    final care = MergeStep.run(
      local.careEvents,
      _read(root, 'careEvents', CareEvent.fromJson),
      (e) => _has(machineIds, e.machineId) && _has(grinderIds, e.grinderId),
    );
    final List<MergeStep<BaseRecord>> steps = [
      waters,
      grinders,
      machines,
      beans,
      packs,
      brews,
      care,
    ];
    int sum(int Function(MergeStep<BaseRecord>) f) =>
        steps.fold(0, (a, s) => a + f(s));
    final unit = (root['settings'] as Map?)?['hardnessUnit'] as String?;
    return ImportOutcome(
      DataSnapshot(
        grinders: grinders.records,
        machines: machines.records,
        waterProfiles: waters.records,
        beans: beans.records,
        packs: packs.records,
        brews: brews.records,
        careEvents: care.records,
        settings: unit == null
            ? local.settings
            : AppSettings(hardnessUnit: HardnessUnit.parse(unit)),
      ),
      ImportResult(
        imported: sum((s) => s.imported),
        unchanged: sum((s) => s.unchanged),
        skipped: sum((s) => s.skipped),
        deletedApplied: sum((s) => s.deletedApplied),
      ),
    );
  }

  static bool _has(Set<String> ids, String? id) =>
      id == null || ids.contains(id);
}
