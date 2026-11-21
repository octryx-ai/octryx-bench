import 'package:flutter/foundation.dart';

import '../core/rules/rule_set.dart';
import '../features/care/data/care_repository.dart';
import '../features/care/domain/care_calculator.dart';
import '../features/care/domain/care_event.dart';
import '../features/care/domain/care_task.dart';
import '../features/equipment/domain/grinder.dart';
import '../features/equipment/domain/machine.dart';
import '../features/water/domain/water_profile.dart';
import 'app_data_brews.dart';

/// Care part of `AppData`: backflush, descale and grinder cleaning (R8).
mixin AppDataCare on ChangeNotifier, AppDataBrews {
  /// Care rules (`care_rules.json`).
  RuleSet get careRules;

  /// Repository holding the care events.
  CareRepository get careRepository;

  /// Live machines.
  List<Machine> get machines;

  /// Live grinders.
  List<Grinder> get grinders;

  /// Live water profiles.
  List<WaterProfile> get waterProfiles;

  /// Care calculator reading [careRules].
  late final CareCalculator careCalculator = CareCalculator(careRules);

  /// Live care events, oldest first.
  List<CareEvent> get careEvents => careRepository.events;

  /// All care tasks, earliest due date first.
  List<CareTask> get careTasks => careCalculator.tasks(
    machines: machines,
    grinders: grinders,
    waterProfilesById: {for (final w in waterProfiles) w.id: w},
    events: careEvents,
    brews: brews,
    today: today,
  );

  /// Records [task] as done now.
  Future<CareEvent> markCareDone(CareTask task) async {
    final event = await careRepository.add(
      kind: task.kind,
      machineId: task.machineId,
      grinderId: task.grinderId,
    );
    notifyListeners();
    return event;
  }

  /// Soft-deletes the care event [id].
  Future<void> deleteCareEvent(String id) async {
    await careRepository.delete(id);
    notifyListeners();
  }
}
