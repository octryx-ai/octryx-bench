import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_no_pack.dart';

final DateTime _now = DateTime.utc(2026, 11, 16, 12);

Bean _bean(String id, {String name = 'Bohne'}) => Bean(
  id: id,
  createdAt: _now,
  updatedAt: _now,
  name: name,
  roaster: 'Roester',
  roastLevel: RoastLevel.medium,
  kind: BeanKind.filter,
);

Pack _pack(String id, String beanId, {DateTime? deletedAt}) => Pack(
  id: id,
  createdAt: _now,
  updatedAt: _now,
  deletedAt: deletedAt,
  beanId: beanId,
  roastDate: DateTime.utc(2026, 11, 4),
  sizeG: 250,
  remainingG: 250,
);

void main() {
  group('beanHasNoPack', () {
    test('is true for a bean without packs', () {
      expect(beanHasNoPack(_bean('a'), const []), isTrue);
    });

    test('is false for a bean with a live pack', () {
      final packs = [_pack('p1', 'a')];
      expect(beanHasNoPack(_bean('a'), packs), isFalse);
    });

    test('ignores packs of other beans', () {
      final packs = [_pack('p1', 'b')];
      expect(beanHasNoPack(_bean('a'), packs), isTrue);
    });

    test('ignores soft-deleted packs', () {
      final packs = [_pack('p1', 'a', deletedAt: _now)];
      expect(beanHasNoPack(_bean('a'), packs), isTrue);
    });
  });

  group('beansWithoutPack', () {
    test('returns the bean without a pack', () {
      final a = _bean('a');
      final b = _bean('b');
      final result = beansWithoutPack([a, b], [_pack('p1', 'b')]);
      expect(result, [a]);
    });

    test('does not return a bean with a pack', () {
      final a = _bean('a');
      expect(beansWithoutPack([a], [_pack('p1', 'a')]), isEmpty);
    });

    test('keeps the input order', () {
      final c = _bean('c', name: 'Cusco');
      final a = _bean('a', name: 'Aethiopien');
      final b = _bean('b', name: 'Brasilien');
      final result = beansWithoutPack([c, a, b], [_pack('p1', 'b')]);
      expect(result, [c, a]);
    });

    test('returns an empty list for no beans', () {
      expect(beansWithoutPack(const [], [_pack('p1', 'a')]), isEmpty);
    });

    test('returns every bean when there are no packs', () {
      final a = _bean('a');
      final b = _bean('b');
      expect(beansWithoutPack([a, b], const []), [a, b]);
    });
  });
}
