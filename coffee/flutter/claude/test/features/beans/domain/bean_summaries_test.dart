import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_summaries.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack_readiness.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';

import '../../../core/test_app_data.dart';

Bean bean(String id, String name, String roaster) => Bean(
  id: id,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  name: name,
  roaster: roaster,
  roastLevel: RoastLevel.medium,
  kind: BeanKind.filter,
);

Pack pack(String id, String beanId, DateTime roast, double rest) => Pack(
  id: id,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  beanId: beanId,
  roastDate: roast,
  sizeG: 250,
  remainingG: rest,
);

void main() {
  final calc = loadTestRest();
  final today = DateTime.utc(2026, 11, 16);

  test('sorted by earliest ready date, packless last, ties by name', () {
    final beans = [
      bean('a', 'Zeta', 'R1'),
      bean('b', 'alpha', 'R2'),
      bean('c', 'Empty', 'R1'),
      bean('d', 'Mid', 'R3'),
      bean('e', 'Beta', 'R3'),
    ];
    final packs = [
      pack('1', 'a', DateTime.utc(2026, 11, 14), 100),
      pack('2', 'a', DateTime.utc(2026, 11, 2), 50), // earliest ready 11-07
      pack('3', 'b', DateTime.utc(2026, 11, 14), 100),
      pack('4', 'd', DateTime.utc(2026, 11, 14), 100),
      pack('5', 'e', DateTime.utc(2026, 11, 20), 100),
    ];
    final list = BeanSummaries.build(
      beans: beans,
      packs: packs,
      calc: calc,
      today: today,
    );
    expect(
      [for (final s in list) s.bean.name],
      ['Zeta', 'alpha', 'Mid', 'Beta', 'Empty'],
    );
    expect(list.first.packs.map((p) => p.id), ['2', '1']);
    expect(list.first.totalRemainingG, 150);
    expect(list.first.earliestReadyDate, DateTime.utc(2026, 11, 7));
    expect(list.last.bestReadiness, isNull);
    expect(list.last.earliestReadyDate, isNull);
  });

  test('too old packs are excluded from stock and best readiness', () {
    final list = BeanSummaries.build(
      beans: [bean('a', 'A', 'R'), bean('b', 'B', 'R')],
      packs: [
        pack('1', 'a', DateTime.utc(2026, 9, 1), 100),
        pack('2', 'a', DateTime.utc(2026, 11, 10), 70),
        pack('3', 'b', DateTime.utc(2026, 9, 1), 100),
      ],
      calc: calc,
      today: today,
    );
    final a = list.firstWhere((s) => s.bean.id == 'a');
    expect(a.totalRemainingG, 70);
    expect(a.bestReadiness!.status, ReadinessStatus.ready);
    final b = list.firstWhere((s) => s.bean.id == 'b');
    expect(b.totalRemainingG, 0);
    expect(b.bestReadiness!.status, ReadinessStatus.tooOld);
  });

  test('deleted packs are ignored', () {
    final dead = pack(
      '1',
      'a',
      DateTime.utc(2026, 11, 1),
      10,
    ).copyWithBase(deletedAt: DateTime.utc(2026, 11, 2));
    final list = BeanSummaries.build(
      beans: [bean('a', 'A', 'R')],
      packs: [dead],
      calc: calc,
      today: today,
    );
    expect(list.single.packs, isEmpty);
  });
}
