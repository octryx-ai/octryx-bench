import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/core/data/base_record.dart';
import 'package:kaffee_begleiter/core/data/fixed_clock.dart';
import 'package:kaffee_begleiter/core/data/in_memory_record_store.dart';

import 'test_record.dart';

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  late FixedClock clock;
  late InMemoryRecordStore<TestRecord> store;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 11, 16, 8, 30, 0, 123));
    store = InMemoryRecordStore<TestRecord>(clock: clock);
  });

  Future<TestRecord> create([String name = 'a']) => store.create(
    (id, now) => TestRecord(id: id, createdAt: now, updatedAt: now, name: name),
  );

  test('create generates UUIDv4 and createdAt == updatedAt', () async {
    final r = await create();
    expect(r.id, matches(_uuidV4));
    expect(r.createdAt, clock.now());
    expect(r.updatedAt, r.createdAt);
    expect(r.deletedAt, isNull);
    expect((await create()).id, isNot(r.id));
  });

  test('get returns record, null for unknown', () async {
    final r = await create();
    expect(await store.get(r.id), r);
    expect(await store.get('nope'), isNull);
  });

  test('update changes fields and bumps updatedAt', () async {
    final r = await create();
    clock.advance(const Duration(seconds: 5));
    final u = await store.update(r.id, (c, now) => c.rename('b'));
    expect(u.name, 'b');
    expect(u.createdAt, r.createdAt);
    expect(u.updatedAt, clock.now());
    expect(u.updatedAt.isAfter(r.updatedAt), isTrue);
  });

  test('update of unknown id throws', () {
    expect(store.update('x', (c, n) => c), throwsStateError);
  });

  test('softDelete sets updatedAt == deletedAt', () async {
    final r = await create();
    clock.advance(const Duration(minutes: 1));
    final d = await store.softDelete(r.id);
    expect(d.deletedAt, clock.now());
    expect(d.updatedAt, d.deletedAt);
    expect(d.createdAt, r.createdAt);
    expect(d.isDeleted, isTrue);
  });

  test('deleted records leave list but stay resolvable', () async {
    final a = await create('a');
    final b = await create('b');
    await store.softDelete(a.id);
    expect((await store.list()).map((r) => r.id), [b.id]);
    expect(await store.list(includeDeleted: true), hasLength(2));
    final got = await store.get(a.id);
    expect(got, isNotNull);
    expect(got!.isDeleted, isTrue);
  });

  test('softDelete of unknown id throws', () {
    expect(store.softDelete('x'), throwsStateError);
  });

  group('JSON', () {
    test('uses UTC ISO-8601 with milliseconds', () async {
      final r = await create();
      final json = r.toJson();
      expect(json['createdAt'], '2026-11-16T08:30:00.123Z');
      expect(json['deletedAt'], isNull);
      expect(json['name'], 'a');
    });

    test('round-trips including deletedAt', () async {
      final r = await create();
      clock.advance(const Duration(seconds: 1));
      final d = await store.softDelete(r.id);
      final back = TestRecord.fromJson(d.toJson());
      expect(back.id, d.id);
      expect(back.createdAt, d.createdAt);
      expect(back.updatedAt, d.updatedAt);
      expect(back.deletedAt, d.deletedAt);
      expect(back.createdAt.isUtc, isTrue);
    });

    test('formatTimestamp converts local time to UTC', () {
      final local = DateTime.utc(2026, 1, 2, 3, 4, 5, 6).toLocal();
      expect(BaseRecord.formatTimestamp(local), '2026-01-02T03:04:05.006Z');
    });

    test('parseTimestamp rejects non-strings', () {
      expect(() => BaseRecord.parseTimestamp(5), throwsFormatException);
    });
  });
}
