import 'package:material_ui/material_ui.dart';

import '../../../../core/format/app_format.dart';
import '../../../../core/l10n_context.dart';
import '../../../beans/presentation/bean_format.dart';
import '../../domain/pack_suggestion.dart';

/// Labels of the pack dropdown of the filter setup.
abstract final class FilterPackOptions {
  /// Pack id to label, in suggestion order; blends that are only a fallback
  /// carry the "backup" mark.
  static Map<String?, String> labels(
    BuildContext context,
    List<PackSuggestion> suggestions,
  ) {
    final l = context.l10n;
    final format = AppFormat.of(context);
    String text(PackSuggestion s) => l.brewPackOption(
      s.bean.name,
      format.date(s.pack.roastDate),
      BeanFormat.grams(l, s.pack.remainingG),
    );
    return {
      for (final s in suggestions)
        s.pack.id: s.fallback ? l.filterPackBackup(text(s)) : text(s),
    };
  }
}
