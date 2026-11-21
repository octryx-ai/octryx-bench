import 'bean.dart';
import 'pack.dart';

/// Whether [bean] has no live pack in [packs] (soft-deleted packs do not
/// count).
bool beanHasNoPack(Bean bean, List<Pack> packs) =>
    !packs.any((p) => p.beanId == bean.id && !p.isDeleted);

/// The beans of [beans] that have no live pack in [packs], in input order.
List<Bean> beansWithoutPack(List<Bean> beans, List<Pack> packs) => [
  for (final b in beans)
    if (beanHasNoPack(b, packs)) b,
];
