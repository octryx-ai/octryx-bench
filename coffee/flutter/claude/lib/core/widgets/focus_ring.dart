import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Draws a 2 dp ring in the accent colour with a 2 dp gap around [child]
/// while [focused]; takes no layout space.
class FocusRing extends StatelessWidget {
  /// Creates a focus ring.
  const FocusRing({
    required this.focused,
    required this.radius,
    required this.child,
    super.key,
  });

  /// Whether the ring is visible.
  final bool focused;

  /// Corner radius of the wrapped element.
  final double radius;

  /// Wrapped element.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const offset = Tokens.focusRingGap + Tokens.focusRingWidth;
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        child,
        if (focused)
          Positioned(
            left: -offset,
            top: -offset,
            right: -offset,
            bottom: -offset,
            child: IgnorePointer(
              child: DecoratedBox(
                key: const Key('focus-ring'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius + offset),
                  border: Border.all(
                    color: AppColors.of(context).accent,
                    width: Tokens.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
