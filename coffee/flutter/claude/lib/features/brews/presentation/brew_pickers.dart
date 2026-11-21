import 'package:material_ui/material_ui.dart';

import '../../../app/app_data.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../beans/presentation/bean_format.dart';

/// The machine, grinder and pack dropdowns of the brew form. Only live
/// records are offered; packs show bean, roast date and remaining grams.
class BrewPickers extends StatelessWidget {
  /// Creates the dropdowns for the chosen ids.
  const BrewPickers({
    required this.data,
    required this.machineId,
    required this.grinderId,
    required this.packId,
    required this.onMachine,
    required this.onGrinder,
    required this.onPack,
    super.key,
  });

  /// Source of the options.
  final AppData data;

  /// Chosen machine, or null.
  final String? machineId;

  /// Chosen grinder, or null.
  final String? grinderId;

  /// Chosen pack, or null.
  final String? packId;

  /// Called with the chosen machine id.
  final ValueChanged<String?> onMachine;

  /// Called with the chosen grinder id.
  final ValueChanged<String?> onGrinder;

  /// Called with the chosen pack id.
  final ValueChanged<String?> onPack;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final format = AppFormat.of(context);
    final machines = {for (final m in data.machines) m.id: m.name};
    final grinders = {for (final g in data.grinders) g.id: g.name};
    final packs = {
      for (final p in data.packs)
        p.id: l.brewPackOption(
          data.beanById(p.beanId)?.name ?? '–',
          format.date(p.roastDate),
          BeanFormat.grams(l, p.remainingG),
        ),
    };
    const gap = SizedBox(height: Tokens.space16);
    return Column(
      children: [
        Semantics(
          container: true,
          child: AppDropdown<String>(
            key: const Key('field-machine'),
            label: l.brewMachine,
            options: machines,
            value: machineId,
            onChanged: onMachine,
          ),
        ),
        gap,
        Semantics(
          container: true,
          child: AppDropdown<String>(
            key: const Key('field-grinder'),
            label: l.brewGrinder,
            options: grinders,
            value: grinderId,
            onChanged: onGrinder,
          ),
        ),
        gap,
        Semantics(
          container: true,
          child: AppDropdown<String>(
            key: const Key('field-pack'),
            label: l.brewPack,
            options: packs,
            value: packId,
            onChanged: onPack,
          ),
        ),
      ],
    );
  }
}
