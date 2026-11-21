import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/features/beans/domain/bean_gradient.dart';

void main() {
  test('FNV-1a reference vectors', () {
    expect(fnv1a32(''), 2166136261);
    expect(fnv1a32('a'), 0xE40C292C);
    expect(fnv1a32('foobar'), 0xBF9CF968);
  });

  test('hue is derived from the lowercase name', () {
    // fnv1a32('ethiopia') = 3232120654; 3232120654 % 36 = 10.
    expect(fnv1a32('ethiopia'), 3232120654);
    expect(BeanGradient.forName('Ethiopia').hue, 25);
    expect(BeanGradient.forName('ETHIOPIA').hue, 25);
  });

  test('hue stays in 15..50', () {
    for (final n in ['', 'a', 'Kenia AA', 'Ünïcode ☕']) {
      final h = BeanGradient.forName(n).hue;
      expect(h, inInclusiveRange(15, 50));
    }
  });

  test('colours', () {
    final g = BeanGradient.forName('Ethiopia');
    expect(g.start(false), (h: 25.0, s: 0.55, l: 0.62));
    expect(g.end(false), (h: 5.0, s: 0.55, l: 0.42));
    expect(g.start(true).l, closeTo(0.50, 1e-9));
    expect(g.end(true).l, closeTo(0.30, 1e-9));
    expect(BeanGradient(50).end(false).h, 30);
  });
}
