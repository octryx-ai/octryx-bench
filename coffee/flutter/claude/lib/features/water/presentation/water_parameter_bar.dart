import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../domain/parameter_result.dart';
import 'water_bar_painter.dart';
import 'water_format.dart';

/// One parameter of the water detail: name, value, a bar of the value against
/// the marked SCA range, and the range text. The bar is error-coloured when
/// the value lies outside the range; unmeasured parameters say so.
class WaterParameterBar extends StatelessWidget {
  /// Creates the row for [result].
  const WaterParameterBar({required this.result, super.key});

  /// Assessment of the parameter.
  final ParameterResult result;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final p = result.parameter;
    final value = result.value;
    final axis = WaterFormat.axisMax(p, value);
    final range = result.range;
    final valueText = value == null
        ? l.notMeasured
        : WaterFormat.value(l, p, value);
    final fill = result.inRange ? c.success : c.error;
    return Padding(
      key: Key('bar-${p.name}'),
      padding: const EdgeInsets.symmetric(vertical: Tokens.space8),
      child: Semantics(
        container: true,
        label:
            '${WaterFormat.label(l, p)}: $valueText, '
            '${l.scaRange(WaterFormat.range(l, p, range))}',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(WaterFormat.label(l, p), style: text.labelLarge),
                ),
                Text(
                  valueText,
                  style: text.bodyMedium!.copyWith(
                    color: value != null && !result.inRange ? c.error : null,
                    fontWeight: value == null ? null : FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Tokens.space4),
            SizedBox(
              height: Tokens.barHeight,
              width: double.infinity,
              child: CustomPaint(
                key: Key('bar-paint-${p.name}'),
                painter: WaterBarPainter(
                  valueFraction: value == null ? 0 : value / axis,
                  rangeStart: range.min == null ? null : range.min! / axis,
                  rangeEnd: range.max == null ? null : range.max! / axis,
                  fillColor: fill,
                  trackColor: c.onSurface.withValues(alpha: Tokens.trackAlpha),
                  bandColor: c.success.withValues(alpha: Tokens.rangeBandAlpha),
                  markColor: c.onSurface,
                ),
              ),
            ),
            const SizedBox(height: Tokens.space4),
            Text(
              l.scaRange(WaterFormat.range(l, p, range)),
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
