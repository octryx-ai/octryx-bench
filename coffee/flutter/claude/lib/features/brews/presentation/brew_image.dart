import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../beans/domain/bean_gradient.dart';

/// Image area of a brew: the gradient of its bean (derived from the bean
/// name) with a cup icon in the middle.
class BrewImage extends StatelessWidget {
  /// Creates the image area; defaults to the 56 dp list size.
  const BrewImage({
    required this.beanName,
    this.width = Tokens.listVisualSize,
    this.height = Tokens.listVisualSize,
    this.iconSize = Tokens.beanIconSize,
    this.radius = Tokens.radiusField,
    super.key,
  });

  /// Bean name; seeds the hue.
  final String beanName;

  /// Width of the area.
  final double width;

  /// Height of the area.
  final double height;

  /// Size of the cup icon.
  final double iconSize;

  /// Corner radius.
  final double radius;

  static Color _color(({double h, double s, double l}) hsl) =>
      HSLColor.fromAHSL(1, hsl.h, hsl.s, hsl.l).toColor();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final gradient = BeanGradient.forName(beanName);
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
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
          child: Center(
            child: Icon(
              Icons.local_cafe,
              size: iconSize,
              color: c.surface.withValues(alpha: Tokens.beanIconAlpha),
            ),
          ),
        ),
      ),
    );
  }
}
