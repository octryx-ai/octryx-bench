import 'dart:convert';

/// FNV-1a 32-bit hash of the UTF-8 bytes of [s].
int fnv1a32(String s) {
  var h = 2166136261;
  for (final b in utf8.encode(s)) {
    h = ((h ^ b) * 16777619) & 0xFFFFFFFF;
  }
  return h;
}

/// Deterministic warm gradient of the "Bohnenkarte", derived from the name.
class BeanGradient {
  /// Creates a gradient with [hue] in degrees (15 to 50).
  const BeanGradient(this.hue);

  /// Gradient for a bean [name] (case-insensitive).
  factory BeanGradient.forName(String name) =>
      BeanGradient(15 + (fnv1a32(name.toLowerCase()) % 36).toDouble());

  /// Base hue in degrees.
  final double hue;

  /// Start colour as HSL (saturation and lightness 0..1).
  ({double h, double s, double l}) start(bool dark) =>
      (h: hue, s: 0.55, l: dark ? 0.50 : 0.62);

  /// End colour as HSL (saturation and lightness 0..1).
  ({double h, double s, double l}) end(bool dark) =>
      (h: (hue + 340) % 360, s: 0.55, l: dark ? 0.30 : 0.42);
}
