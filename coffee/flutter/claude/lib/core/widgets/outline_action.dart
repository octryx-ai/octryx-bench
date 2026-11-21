import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Secondary action: outlined button in the accent colour, or in [color].
class OutlineAction extends StatelessWidget {
  /// Creates the button.
  const OutlineAction({
    required this.label,
    required this.onPressed,
    this.color,
    super.key,
  });

  /// Button text.
  final String label;

  /// Tap callback.
  final VoidCallback? onPressed;

  /// Text and border colour; the accent if null.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? AppColors.of(context).accent;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(Tokens.touchTarget, Tokens.touchTarget),
        foregroundColor: tone,
        side: BorderSide(color: tone),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusField),
        ),
      ),
      child: Text(label),
    );
  }
}
