import 'package:material_ui/material_ui.dart';

import '../../../app/app_data.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../beans/presentation/bean_format.dart';
import '../../beans/presentation/stat_tile.dart';
import '../domain/brew.dart';
import 'brew_format.dart';

/// Key figures of a brew in two columns.
class BrewTiles extends StatelessWidget {
  /// Creates the tiles for [brew].
  const BrewTiles({required this.brew, required this.data, super.key});

  /// Brew shown.
  final Brew brew;

  /// Resolves grinder, machine and water names.
  final AppData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final format = AppFormat.of(context);
    final local = brew.startedAt.toLocal();
    final water = brew.waterProfileId;
    final machine = brew.machineId;
    final filter = brew.method.isFilter;
    final entries = <(String, String, String)>[
      ('setting', l.brewGrind, BrewFormat.setting(brew.grindSetting)),
      ('dose', l.brewDose, BeanFormat.grams(l, brew.doseG)),
      ('purge', l.brewPurge, BeanFormat.grams(l, brew.purgeG)),
      if (filter) ...[
        (
          'water-total',
          l.brewWaterTotal,
          brew.waterTotalG == null
              ? '–'
              : BeanFormat.grams(l, brew.waterTotalG!),
        ),
        (
          'bloom',
          l.brewBloom,
          brew.bloomG == null ? '–' : BeanFormat.grams(l, brew.bloomG!),
        ),
      ] else
        (
          'yield',
          l.brewYield,
          brew.yieldG == null ? '–' : BeanFormat.grams(l, brew.yieldG!),
        ),
      ('ratio', l.brewRatio, BrewFormat.ratio(brew)),
      ('time', filter ? l.brewDrawdown : l.brewTime, BrewFormat.time(l, brew)),
      (
        'taste',
        l.brewTaste,
        brew.taste == null ? '–' : BrewFormat.taste(l, brew.taste!),
      ),
      (
        'rating',
        l.brewRating,
        brew.rating == null ? '–' : BrewFormat.rating(brew.rating!),
      ),
      ('grinder', l.brewGrinder, data.grinderById(brew.grinderId)?.name ?? '–'),
      if (!filter)
        (
          'machine',
          l.brewMachine,
          (machine == null ? null : data.machineById(machine)?.name) ?? '–',
        ),
      (
        'water',
        l.brewWater,
        (water == null ? null : data.waterProfileById(water)?.name) ?? '–',
      ),
      (
        'started',
        l.brewStarted,
        '${format.date(local)} ${BrewFormat.clock(local)}',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - Tokens.space12) / 2;
        return Wrap(
          spacing: Tokens.space12,
          runSpacing: Tokens.space12,
          children: [
            for (final e in entries)
              SizedBox(
                width: width,
                child: StatTile(
                  key: Key('tile-${e.$1}'),
                  label: e.$2,
                  value: e.$3,
                ),
              ),
            if (brew.pours.isNotEmpty)
              SizedBox(
                width: constraints.maxWidth,
                child: StatTile(
                  key: const Key('tile-pours'),
                  label: l.brewPours,
                  value: [
                    for (final p in brew.pours)
                      '${BrewFormat.minutes(p.atS)} → '
                          '${BeanFormat.grams(l, p.cumulativeG)}',
                  ].join(', '),
                ),
              ),
          ],
        );
      },
    );
  }
}
