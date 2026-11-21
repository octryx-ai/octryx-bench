import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_kind.dart';
import 'package:kaffee_begleiter/features/beans/domain/pack.dart';
import 'package:kaffee_begleiter/features/beans/domain/roast_level.dart';

void main() {
  final t = DateTime.utc(2026, 11, 16, 8, 30);

  test('bean round trip and clearing min stock', () {
    final b = Bean(
      id: 'b',
      createdAt: t,
      updatedAt: t,
      name: 'N',
      roaster: 'R',
      roastLevel: RoastLevel.mediumDark,
      kind: BeanKind.allround,
      minStockG: 200,
    );
    final back = Bean.fromJson(b.toJson());
    expect(back.toJson(), b.toJson());
    expect(back.leadTimeDays, 3);
    expect(b.copyWith(clearMinStock: true).minStockG, isNull);
    expect(b.copyWith(name: 'M').minStockG, 200);
  });

  test('pack round trip with date-only roast date', () {
    final p = Pack(
      id: 'p',
      createdAt: t,
      updatedAt: t,
      beanId: 'b',
      roastDate: DateTime.utc(2026, 11, 1),
      sizeG: 250,
      remainingG: 250,
      openedAt: t,
    );
    final json = p.toJson();
    expect(json['roastDate'], '2026-11-01');
    expect(json['openedAt'], '2026-11-16T08:30:00.000Z');
    expect(Pack.fromJson(json).toJson(), json);
    expect(p.copyWith(clearOpenedAt: true).openedAt, isNull);
  });
}
