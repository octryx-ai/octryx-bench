import '../../beans/domain/bean.dart';
import '../../beans/domain/bean_kind.dart';
import '../../beans/domain/pack.dart';
import '../../beans/domain/rest_calculator.dart';
import '../../beans/domain/rest_method.dart';
import 'pack_suggestion.dart';

/// Suggests packs for filter brewing (SPEC R3).
class FilterPackSuggester {
  /// Creates a suggester using the rules of [rest].
  FilterPackSuggester(this._rest);

  final RestCalculator _rest;

  /// Ready, non-empty packs, earliest roast first. Espresso blends appear
  /// (with `fallback`) only if no other pack is ready.
  List<PackSuggestion> suggest({
    required List<Pack> packs,
    required Map<String, Bean> beansById,
    required DateTime today,
  }) {
    final main = <PackSuggestion>[];
    final blends = <PackSuggestion>[];
    for (final p in packs) {
      final bean = beansById[p.beanId];
      if (bean == null || p.isDeleted || p.remainingG <= 0) continue;
      final now = RestCalculator.dateOnly(today);
      final readyOn = _rest.readyDate(
        p.roastDate,
        RestMethod.filter,
        bean.roastLevel,
      );
      if (now.isBefore(readyOn) ||
          !now.isBefore(_rest.staleDate(p.roastDate))) {
        continue;
      }
      final blend = bean.kind == BeanKind.espressoBlend;
      (blend ? blends : main).add(
        PackSuggestion(pack: p, bean: bean, fallback: blend),
      );
    }
    final list = main.isNotEmpty ? main : blends;
    list.sort((a, b) => a.pack.roastDate.compareTo(b.pack.roastDate));
    return list;
  }
}
