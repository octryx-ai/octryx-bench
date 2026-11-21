import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';
import 'package:kaffee_begleiter/features/brews/domain/filter_pack_suggester.dart';

import '../../../core/test_app_data.dart';

final _t = DateTime.utc(2026, 1, 1);
final _today = DateTime.utc(2026, 11, 16);

Bean _bean(String id, BeanKind kind, {RoastLevel l = RoastLevel.medium}) =>
    Bean(
      id: id,
      createdAt: _t,
      updatedAt: _t,
      name: id,
      roaster: 'R',
      roastLevel: l,
      kind: kind,
    );

Pack _pack(
  String id,
  String bean,
  int daysAgo, {
  double remaining = 250,
  bool deleted = false,
}) => Pack(
  id: id,
  createdAt: _t,
  updatedAt: _t,
  deletedAt: deleted ? _t : null,
  beanId: bean,
  roastDate: DateTime.utc(2026, 11, 16 - daysAgo),
  sizeG: 250,
  remainingG: remaining,
);

void main() {
  final suggester = FilterPackSuggester(loadTestRest());
  final beans = {
    'f': _bean('f', BeanKind.filter),
    'a': _bean('a', BeanKind.allround),
    'e': _bean('e', BeanKind.espressoBlend),
  };

  List<String> ids(List<Pack> packs) => [
    for (final s in suggester.suggest(
      packs: packs,
      beansById: beans,
      today: _today,
    ))
      s.pack.id,
  ];

  test('sorted by earliest roast date, allround is primary', () {
    final r = suggester.suggest(
      packs: [_pack('p1', 'f', 6), _pack('p2', 'a', 20), _pack('p3', 'f', 10)],
      beansById: beans,
      today: _today,
    );
    expect([for (final s in r) s.pack.id], ['p2', 'p3', 'p1']);
    expect(r.every((s) => !s.fallback), isTrue);
  });

  test('filter rest applies to allround (5 days medium)', () {
    expect(ids([_pack('p', 'a', 5)]), ['p']);
    expect(ids([_pack('p', 'a', 4)]), isEmpty);
  });

  test('resting, too old, empty and deleted packs are excluded', () {
    expect(
      ids([
        _pack('resting', 'f', 2),
        _pack('old', 'f', 45),
        _pack('empty', 'f', 10, remaining: 0),
        _pack('gone', 'f', 10, deleted: true),
        _pack('ok', 'f', 44),
      ]),
      ['ok'],
    );
  });

  test('blends only when nothing else is ready', () {
    expect(ids([_pack('b', 'e', 10), _pack('p', 'f', 10)]), ['p']);
    final r = suggester.suggest(
      packs: [_pack('b2', 'e', 8), _pack('b1', 'e', 12), _pack('rest', 'f', 1)],
      beansById: beans,
      today: _today,
    );
    expect([for (final s in r) s.pack.id], ['b1', 'b2']);
    expect(r.every((s) => s.fallback), isTrue);
  });

  test('resting blend is never suggested', () {
    expect(ids([_pack('b', 'e', 2)]), isEmpty);
  });
}
