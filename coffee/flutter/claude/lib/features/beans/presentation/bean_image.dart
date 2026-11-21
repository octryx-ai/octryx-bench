import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../domain/bean_gradient.dart';
import '../domain/roast_level.dart';
import 'roast_dots.dart';

/// Image area of a bean: 135 degree HSL gradient derived from the name, a
/// centred bean icon and the roast-level dots at the bottom right.
class BeanImage extends StatelessWidget {
  /// Creates the image area; defaults to the 56 dp list size.
  const BeanImage({
    required this.name,
    required this.roastLevel,
    this.width = Tokens.listVisualSize,
    this.height = Tokens.listVisualSize,
    this.iconSize = Tokens.beanIconSize,
    this.radius = Tokens.radiusField,
    this.dotInset = Tokens.space4,
    super.key,
  });

  /// Bean name; seeds the hue.
  final String name;

  /// Roast level shown as dots.
  final RoastLevel roastLevel;

  /// Width of the area.
  final double width;

  /// Height of the area.
  final double height;

  /// Size of the bean icon.
  final double iconSize;

  /// Corner radius.
  final double radius;

  /// Distance of the roast dots from the right and bottom edge.
  final double dotInset;

  static Color _color(({double h, double s, double l}) hsl) =>
      HSLColor.fromAHSL(1, hsl.h, hsl.s, hsl.l).toColor();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final gradient = BeanGradient.forName(name);
    return Semantics(
      image: true,
      label: context.l10n.beanImageLabel(name),
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          key: Key('bean-image-${gradient.hue.round()}'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _color(gradient.start(c.isDark)),
                _color(gradient.end(c.isDark)),
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.coffee,
                  size: iconSize,
                  color: c.surface.withValues(alpha: Tokens.beanIconAlpha),
                ),
              ),
              Positioned(
                right: dotInset,
                bottom: dotInset,
                child: RoastDots(level: roastLevel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
