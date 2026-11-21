import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import 'sg_section.dart';
import 'sg_state.dart';

/// Style-guide: colour tokens of the current theme.
class SgColorsSection extends StatelessWidget {
  /// Creates the section.
  const SgColorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final swatches = <String, Color>{
      'primary': Tokens.primary,
      'primaryHover': Tokens.primaryHover,
      'primaryPressed': Tokens.primaryPressed,
      'surface': c.surface,
      'surfaceVariant': c.surfaceVariant,
      'onSurface': c.onSurface,
      'success': c.success,
      'warning': c.warning,
      'error': c.error,
    };
    return SgSection(
      title: context.l10n.sgColors,
      children: [
        for (final e in swatches.entries)
          SgState(
            keyName: 'color-${e.key}',
            label: '${e.key} ${_hex(e.value)}',
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: e.value,
                borderRadius: BorderRadius.circular(Tokens.radiusField),
                border: Border.all(color: c.border, width: Tokens.borderWidth),
              ),
              child: const SizedBox(
                width: Tokens.swatchSize,
                height: Tokens.swatchSize,
              ),
            ),
          ),
      ],
    );
  }

  static String _hex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
