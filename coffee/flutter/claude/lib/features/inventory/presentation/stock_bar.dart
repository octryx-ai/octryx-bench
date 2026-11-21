import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';

/// Bestands-Balken: 8 dp high, the full width stands for twice the order
/// point, the fill for the total stock and a 2 dp marker at 50 % for the
/// order point itself (SPEC "Bestands-Balken", LF11).
class StockBar extends StatelessWidget {
  /// Creates a bar for [stockG] against [orderPoint]; a [semanticLabel]
  /// makes it readable by screen readers, otherwise it is excluded.
  const StockBar({
    required this.stockG,
    required this.orderPoint,
    this.semanticLabel,
    super.key,
  });

  /// Total stock of the bean in grams.
  final double stockG;

  /// Order point in grams (may be 0).
  final double orderPoint;

  /// Accessible description, or null to hide the bar from screen readers.
  final String? semanticLabel;

  /// Fill share of the bar: `min(1, stock / (2 * orderPoint))`. With an
  /// order point of 0 any stock fills the bar.
  static double fractionFor(double stockG, double orderPoint) {
    if (stockG <= 0) return 0;
    if (orderPoint <= 0) return 1;
    return (stockG / (2 * orderPoint)).clamp(0.0, 1.0);
  }

  /// Fill colour: success above the order point, warning at or below it;
  /// null for an empty stock (no fill, error border instead).
  static Color? colorFor(AppColors c, double stockG, double orderPoint) {
    if (stockG <= 0) return null;
    return stockG > orderPoint ? c.success : c.warning;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fill = colorFor(c, stockG, orderPoint);
    final radius = BorderRadius.circular(Tokens.barRadius);
    final bar = SizedBox(
      key: const Key('stock-bar'),
      height: Tokens.barHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.onSurface.withValues(alpha: Tokens.trackAlpha),
          borderRadius: radius,
          border: fill == null
              ? Border.all(color: c.error, width: Tokens.borderWidth)
              : null,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (fill != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fractionFor(stockG, orderPoint),
                    heightFactor: 1,
                    child: ColoredBox(
                      key: const Key('stock-bar-fill'),
                      color: fill,
                    ),
                  ),
                ),
              Align(
                child: SizedBox(
                  width: Tokens.barMarkWidth,
                  child: ColoredBox(
                    key: const Key('stock-bar-marker'),
                    color: c.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: bar);
    return Semantics(
      label: label,
      child: ExcludeSemantics(child: bar),
    );
  }
}
