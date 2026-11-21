import 'rest_method.dart';

/// Intended use of a bean (SPEC section 3).
enum BeanKind {
  /// Blend made for espresso.
  espressoBlend('espressoBlend', RestMethod.espresso),

  /// Roasted for filter brewing.
  filter('filter', RestMethod.filter),

  /// Suits both; rests like espresso.
  allround('allround', RestMethod.espresso);

  const BeanKind(this.code, this.restMethod);

  /// Stable code used in JSON.
  final String code;

  /// Resting method applied to this kind.
  final RestMethod restMethod;

  /// Parses [code]; throws [FormatException] if unknown.
  static BeanKind parse(String code) => values.firstWhere(
    (v) => v.code == code,
    orElse: () => throw FormatException('Unknown bean kind', code),
  );
}
