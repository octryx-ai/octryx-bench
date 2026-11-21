import 'package:flutter/foundation.dart';

import '../features/beans/data/beans_repository.dart';
import '../features/beans/domain/bean.dart';
import '../features/beans/domain/bean_kind.dart';
import '../features/beans/domain/pack.dart';
import '../features/beans/domain/roast_level.dart';

/// Bean and pack part of `AppData`: stock keeping with soft delete.
mixin AppDataBeans on ChangeNotifier {
  /// Repository holding beans and packs.
  BeansRepository get beansRepository;

  /// Live beans.
  List<Bean> get beans => beansRepository.beans;

  /// Live packs.
  List<Pack> get packs => beansRepository.packs;

  /// Live packs of bean [beanId].
  List<Pack> packsOf(String beanId) => beansRepository.packsOf(beanId);

  /// Bean with [id] (also if soft-deleted), or null.
  Bean? beanById(String id) => beansRepository.beanById(id);

  /// Pack with [id] (also if soft-deleted), or null.
  Pack? packById(String id) => beansRepository.packById(id);

  /// Creates a bean.
  Future<Bean> addBean({
    required String name,
    required String roaster,
    required RoastLevel roastLevel,
    required BeanKind kind,
    double? minStockG,
    int leadTimeDays = 3,
  }) => _done(
    beansRepository.addBean(
      name: name,
      roaster: roaster,
      roastLevel: roastLevel,
      kind: kind,
      minStockG: minStockG,
      leadTimeDays: leadTimeDays,
    ),
  );

  /// Saves changes to [bean].
  Future<Bean> updateBean(Bean bean) => _done(beansRepository.updateBean(bean));

  /// Soft-deletes bean [id] together with its packs.
  Future<void> deleteBean(String id) => _done(beansRepository.deleteBean(id));

  /// Creates a full pack of bean [beanId].
  Future<Pack> addPack({
    required String beanId,
    required DateTime roastDate,
    required double sizeG,
  }) => _done(
    beansRepository.addPack(beanId: beanId, roastDate: roastDate, sizeG: sizeG),
  );

  /// Saves changes to [pack].
  Future<Pack> updatePack(Pack pack) => _done(beansRepository.updatePack(pack));

  /// Soft-deletes the pack [id].
  Future<void> deletePack(String id) => _done(beansRepository.deletePack(id));

  /// Marks pack [id] as opened now (no change if already opened).
  Future<Pack> openPack(String id) => _done(beansRepository.openPack(id));

  Future<R> _done<R>(Future<R> work) async {
    final result = await work;
    notifyListeners();
    return result;
  }
}
