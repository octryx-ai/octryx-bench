import '../../../core/rules/rule_set.dart';
import '../../beans/domain/rest_calculator.dart';
import '../../brews/domain/brew.dart';
import '../../brews/domain/brew_method.dart';
import '../../equipment/domain/grinder.dart';
import '../../equipment/domain/machine.dart';
import '../../water/domain/water_profile.dart';
import 'care_event.dart';
import 'care_kind.dart';
import 'care_status.dart';
import 'care_task.dart';

/// Computes the care tasks of SPEC R8 from `care_rules.json`.
///
/// Missing rule keys fall back to the spec values.
class CareCalculator {
  /// Creates a calculator reading the `backflush.*`, `descale.*` and
  /// `grinderClean.days` rules.
  CareCalculator(RuleSet rules)
    : backflushShots = _n(rules, 'backflush.shots', 200),
      backflushDays = _n(rules, 'backflush.days', 7),
      _hardMin = _n(rules, 'descale.hard.minPpm', 150),
      _hardDays = _n(rules, 'descale.hard.days', 30),
      _mediumMin = _n(rules, 'descale.medium.minPpm', 100),
      _mediumDays = _n(rules, 'descale.medium.days', 60),
      _softDays = _n(rules, 'descale.soft.days', 90),
      _grinderDays = _n(rules, 'grinderClean.days', 28);

  /// Shots after which a backflush is due.
  final int backflushShots;

  /// Days after which a backflush is due.
  final int backflushDays;

  final int _hardMin;
  final int _hardDays;
  final int _mediumMin;
  final int _mediumDays;
  final int _softDays;
  final int _grinderDays;

  static int _n(RuleSet r, String key, int fallback) =>
      r.maybeEntry(key) == null ? fallback : r.number(key).toInt();

  /// Descale interval in days for water of [ppm] hardness: above the hard
  /// limit (150) hard, from the medium limit (100) medium, else soft. No
  /// water profile (null) counts as medium.
  int descaleDays(double? ppm) {
    if (ppm == null) return _mediumDays;
    if (ppm > _hardMin) return _hardDays;
    if (ppm >= _mediumMin) return _mediumDays;
    return _softDays;
  }

  /// All tasks, earliest due date first (due ones on top).
  ///
  /// Every machine gets a backflush and a descale task, every grinder a
  /// cleaning task. Without a recorded event a task is due today ("first
  /// care is due immediately"). Backflush is also due once [backflushShots]
  /// espresso shots were brewed since the last backflush. [events] and
  /// [brews] should be live ones.
  List<CareTask> tasks({
    required Iterable<Machine> machines,
    required Iterable<Grinder> grinders,
    required Map<String, WaterProfile> waterProfilesById,
    required Iterable<CareEvent> events,
    required Iterable<Brew> brews,
    required DateTime today,
  }) {
    final now = RestCalculator.dateOnly(today);
    DateTime? last(CareKind k, bool Function(CareEvent) of) {
      DateTime? best;
      for (final e in events) {
        if (e.isDeleted || e.kind != k || !of(e)) continue;
        if (best == null || e.doneAt.isAfter(best)) best = e.doneAt;
      }
      return best;
    }

    int shots(Machine m, DateTime? since) => brews
        .where(
          (b) =>
              !b.isDeleted &&
              b.method == BrewMethod.espresso &&
              b.machineId == m.id &&
              (since == null || b.startedAt.isAfter(since)),
        )
        .length;

    final result = <CareTask>[];
    for (final m in machines) {
      final back = last(CareKind.backflush, (e) => e.machineId == m.id);
      final backShots = shots(m, back);
      result.add(
        _task(
          CareKind.backflush,
          m.id,
          null,
          m.name,
          back,
          now,
          backflushDays,
          backShots,
          shotsDue: backShots >= backflushShots,
        ),
      );
      final desc = last(CareKind.descale, (e) => e.machineId == m.id);
      final water = waterProfilesById[m.defaultWaterProfileId];
      result.add(
        _task(
          CareKind.descale,
          m.id,
          null,
          m.name,
          desc,
          now,
          descaleDays(water?.hardnessPpm),
          shots(m, desc),
        ),
      );
    }
    for (final g in grinders) {
      final done = last(CareKind.grinderClean, (e) => e.grinderId == g.id);
      result.add(
        _task(
          CareKind.grinderClean,
          null,
          g.id,
          g.name,
          done,
          now,
          _grinderDays,
          0,
        ),
      );
    }
    result.sort((a, b) {
      final byDate = a.dueDate.compareTo(b.dueDate);
      return byDate != 0 ? byDate : a.kind.index.compareTo(b.kind.index);
    });
    return result;
  }

  CareTask _task(
    CareKind kind,
    String? machineId,
    String? grinderId,
    String name,
    DateTime? lastDone,
    DateTime today,
    int interval,
    int shotsSince, {
    bool shotsDue = false,
  }) {
    final DateTime dueDate;
    String? hint;
    if (shotsDue) {
      dueDate = today;
      hint = 'backflush.shots';
    } else if (lastDone == null) {
      dueDate = today;
      hint = 'never';
    } else {
      final day = RestCalculator.dateOnly(lastDone.toLocal());
      dueDate = DateTime.utc(day.year, day.month, day.day + interval);
    }
    final daysLeft = shotsDue || lastDone == null
        ? 0
        : dueDate.difference(today).inDays;
    return CareTask(
      kind: kind,
      machineId: machineId,
      grinderId: grinderId,
      name: name,
      lastDone: lastDone,
      shotsSince: shotsSince,
      dueDate: dueDate,
      daysLeft: daysLeft,
      ringFraction: (daysLeft / interval).clamp(0.0, 1.0),
      status: daysLeft <= 0
          ? CareStatus.due
          : daysLeft <= 2
          ? CareStatus.soon
          : CareStatus.ok,
      hintKey: hint,
    );
  }
}
