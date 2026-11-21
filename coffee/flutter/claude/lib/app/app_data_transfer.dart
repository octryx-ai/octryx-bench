import 'package:flutter/foundation.dart';

import '../core/data/base_record.dart';

import '../features/beans/domain/bean.dart';
import '../features/beans/domain/pack.dart';
import '../features/brews/domain/brew.dart';
import '../features/care/domain/care_event.dart';
import '../features/equipment/domain/grinder.dart';
import '../features/equipment/domain/machine.dart';
import '../features/settings/data/app_settings.dart';
import '../features/transfer/domain/data_snapshot.dart';
import '../features/water/domain/water_profile.dart';
import 'app_data_brews.dart';
import 'app_data_care.dart';
import 'record_collection.dart';
import 'record_swap.dart';

/// Export, import and "delete all data" (SPEC section 6).
mixin AppDataTransfer on ChangeNotifier, AppDataBrews, AppDataCare {
  /// Collection of all grinders (including soft-deleted ones).
  RecordCollection<Grinder> get grinderCollection;

  /// Collection of all machines (including soft-deleted ones).
  RecordCollection<Machine> get machineCollection;

  /// Collection of all water profiles (including soft-deleted ones).
  RecordCollection<WaterProfile> get waterCollection;

  /// The settings.
  AppSettings get settings;
  set settings(AppSettings value);

  /// Every record including soft-deleted ones, and the settings.
  DataSnapshot snapshot() => DataSnapshot(
    grinders: grinderCollection.all,
    machines: machineCollection.all,
    waterProfiles: waterCollection.all,
    beans: beansRepository.beanCollection.all,
    packs: beansRepository.packCollection.all,
    brews: brewsRepository.collection.all,
    careEvents: careRepository.collection.all,
    settings: settings,
  );

  /// Replaces all data by [next] as one transaction: if writing any
  /// collection fails, the already written ones are rolled back and the
  /// error is rethrown. Listeners are notified once after success.
  Future<void> restore(DataSnapshot next) async {
    final swaps = <RecordSwap<BaseRecord>>[
      RecordSwap<Grinder>(grinderCollection, next.grinders),
      RecordSwap<Machine>(machineCollection, next.machines),
      RecordSwap<WaterProfile>(waterCollection, next.waterProfiles),
      RecordSwap<Bean>(beansRepository.beanCollection, next.beans),
      RecordSwap<Pack>(beansRepository.packCollection, next.packs),
      RecordSwap<Brew>(brewsRepository.collection, next.brews),
      RecordSwap<CareEvent>(careRepository.collection, next.careEvents),
    ];
    final started = <RecordSwap<BaseRecord>>[];
    try {
      for (final s in swaps) {
        started.add(s);
        await s.apply();
      }
    } catch (_) {
      for (final s in started.reversed) {
        await s.undo();
      }
      await brewsRepository.load();
      rethrow;
    }
    // The settings are applied last and synchronously: they can only change
    // after every collection was written, so a rollback never leaves a
    // half-applied settings change.
    settings = next.settings;
    await brewsRepository.load();
    notifyListeners();
  }

  /// "Delete all data": empties every collection including soft-deleted
  /// records and resets the settings. This is the only hard delete in the
  /// app.
  Future<void> clearAll() => restore(const DataSnapshot());
}
