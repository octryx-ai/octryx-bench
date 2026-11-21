import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_data.dart';
import 'package:kaffee_begleiter/core/data/fixed_clock.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack_readiness.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';

import '../core/test_app_data.dart';

void main() {
  late FixedClock clock;
  late AppData data;

  setUp(() async {
    clock = FixedClock(DateTime.utc(2026, 11, 16, 8));
    data = await loadTestAppData(clock: clock);
  });

  Future<String> bean() async => (await data.addBean(
    name: 'Ethiopia',
    roaster: 'Roest',
    roastLevel: RoastLevel.medium,
    kind: BeanKind.filter,
  )).id;

  test('addPack stores date-only roast date, full remaining', () async {
    final id = await bean();
    final p = await data.addPack(
      beanId: id,
      roastDate: DateTime(2026, 11, 1, 15),
      sizeG: 250,
    );
    expect(p.roastDate, DateTime.utc(2026, 11, 1));
    expect(p.remainingG, 250);
    expect(p.openedAt, isNull);
    expect(data.packsOf(id), hasLength(1));
    expect(
      data.beanSummaries.single.bestReadiness!.status,
      ReadinessStatus.ready,
    );
  });

  test('openPack sets openedAt once', () async {
    final id = await bean();
    final p = await data.addPack(
      beanId: id,
      roastDate: DateTime(2026, 11, 1),
      sizeG: 250,
    );
    clock.advance(const Duration(hours: 1));
    final opened = await data.openPack(p.id);
    expect(opened.openedAt, DateTime.utc(2026, 11, 16, 9));
    clock.advance(const Duration(hours: 1));
    expect((await data.openPack(p.id)).openedAt, DateTime.utc(2026, 11, 16, 9));
    expect(data.packById(p.id)!.openedAt, isNotNull);
  });

  test('deleteBean soft-deletes bean and packs', () async {
    final id = await bean();
    final p = await data.addPack(
      beanId: id,
      roastDate: DateTime(2026, 11, 1),
      sizeG: 250,
    );
    clock.advance(const Duration(minutes: 5));
    await data.deleteBean(id);
    expect(data.beans, isEmpty);
    expect(data.packs, isEmpty);
    expect(data.packsOf(id), isEmpty);
    expect(data.beanSummaries, isEmpty);
    final b = data.beanById(id)!;
    expect(b.deletedAt, isNotNull);
    expect(b.updatedAt, b.deletedAt);
    expect(data.packById(p.id)!.isDeleted, isTrue);
  });

  test('deletePack and updateBean notify and persist', () async {
    final id = await bean();
    var n = 0;
    data.addListener(() => n++);
    await data.updateBean(data.beanById(id)!.copyWith(name: 'Kenia'));
    expect(data.beans.single.name, 'Kenia');
    final p = await data.addPack(
      beanId: id,
      roastDate: DateTime(2026, 11, 1),
      sizeG: 100,
    );
    await data.deletePack(p.id);
    expect(data.packs, isEmpty);
    expect(n, 3);
  });
}
