import '../../beans/domain/bean.dart';
import '../../beans/domain/pack.dart';

/// A pack proposed for a filter brew.
class PackSuggestion {
  /// Creates a suggestion.
  const PackSuggestion({
    required this.pack,
    required this.bean,
    this.fallback = false,
  });

  /// The suggested pack.
  final Pack pack;

  /// The bean of [pack].
  final Bean bean;

  /// True for an espresso blend suggested only because nothing else is ready.
  final bool fallback;
}
