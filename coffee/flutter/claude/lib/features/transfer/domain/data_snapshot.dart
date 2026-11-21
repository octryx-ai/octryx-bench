import '../../beans/domain/bean.dart';
import '../../beans/domain/pack.dart';
import '../../brews/domain/brew.dart';
import '../../care/domain/care_event.dart';
import '../../equipment/domain/grinder.dart';
import '../../equipment/domain/machine.dart';
import '../../settings/data/app_settings.dart';
import '../../water/domain/water_profile.dart';

/// Every record (soft-deleted ones included) and the settings at one point
/// in time; the unit exchanged by export, import and "delete all data".
class DataSnapshot {
  /// Creates a snapshot; all lists default to empty.
  const DataSnapshot({
    this.grinders = const [],
    this.machines = const [],
    this.waterProfiles = const [],
    this.beans = const [],
    this.packs = const [],
    this.brews = const [],
    this.careEvents = const [],
    this.settings = const AppSettings(),
  });

  /// All grinders.
  final List<Grinder> grinders;

  /// All machines.
  final List<Machine> machines;

  /// All water profiles.
  final List<WaterProfile> waterProfiles;

  /// All beans.
  final List<Bean> beans;

  /// All packs.
  final List<Pack> packs;

  /// All brews.
  final List<Brew> brews;

  /// All care events.
  final List<CareEvent> careEvents;

  /// The settings.
  final AppSettings settings;
}
