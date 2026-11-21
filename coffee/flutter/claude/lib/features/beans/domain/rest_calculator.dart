import '../../../core/rules/rule_set.dart';
import 'bean.dart';
import 'pack.dart';
import 'pack_readiness.dart';
import 'rest_method.dart';
import 'roast_level.dart';

/// Computes resting and stale dates (SPEC R3) from `rest_rules.json`.
///
/// Missing rule keys fall back to the spec table.
class RestCalculator {
  /// Creates a calculator reading `rest.<method>.<level>` and `stale.days`.
  RestCalculator(RuleSet rules)
    : _rest = {
        for (final m in RestMethod.values)
          for (final l in RoastLevel.values)
            (m, l): _number(rules, 'rest.${m.name}.${l.code}', _table[m]![l]!),
      },
      _staleDays = _number(rules, 'stale.days', 45);

  /// Calculator using the spec defaults.
  RestCalculator.defaults() : this(RuleSet(const []));

  /// Asset holding the rest rules.
  static const String assetName = 'assets/rest_rules.json';

  static const Map<RestMethod, Map<RoastLevel, int>> _table = {
    RestMethod.filter: {
      RoastLevel.light: 7,
      RoastLevel.medium: 5,
      RoastLevel.mediumDark: 4,
      RoastLevel.dark: 3,
    },
    RestMethod.espresso: {
      RoastLevel.light: 14,
      RoastLevel.medium: 10,
      RoastLevel.mediumDark: 7,
      RoastLevel.dark: 5,
    },
  };

  final Map<(RestMethod, RoastLevel), int> _rest;
  final int _staleDays;

  static int _number(RuleSet rules, String key, int fallback) =>
      rules.maybeEntry(key) == null ? fallback : rules.number(key).toInt();

  /// Strips time and zone: the calendar day of [d] as UTC midnight.
  static DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  /// Resting days for [m] and [l].
  int restDays(RestMethod m, RoastLevel l) => _rest[(m, l)]!;

  /// First ready day for a roast on [roastDate].
  DateTime readyDate(DateTime roastDate, RestMethod m, RoastLevel l) =>
      _add(roastDate, restDays(m, l));

  /// First day a roast on [roastDate] counts as too old.
  DateTime staleDate(DateTime roastDate) => _add(roastDate, _staleDays);

  /// Readiness of [p] of bean [b] on [today]; [method] overrides the rest
  /// method of the bean kind (e.g. the filter rest for an allround bean).
  PackReadiness readiness(
    Pack p,
    Bean b,
    DateTime today, {
    RestMethod? method,
  }) {
    final now = dateOnly(today);
    final ready = readyDate(
      p.roastDate,
      method ?? b.kind.restMethod,
      b.roastLevel,
    );
    final stale = staleDate(p.roastDate);
    final ReadinessStatus status;
    if (!now.isBefore(stale)) {
      status = ReadinessStatus.tooOld;
    } else if (now.isBefore(ready)) {
      status = ReadinessStatus.resting;
    } else {
      status = ReadinessStatus.ready;
    }
    return PackReadiness(
      status: status,
      readyDate: ready,
      staleDate: stale,
      daysLeft: status == ReadinessStatus.resting
          ? ready.difference(now).inDays
          : 0,
    );
  }

  static DateTime _add(DateTime d, int days) =>
      DateTime.utc(d.year, d.month, d.day + days);
}
