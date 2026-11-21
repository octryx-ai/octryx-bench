import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/tokens.dart';

/// One entry of the desktop sidebar (min 48 dp high).
class SidebarItem extends StatelessWidget {
  /// Creates an entry.
  const SidebarItem({
    required this.itemKey,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// Stable key of the tappable area.
  final Key itemKey;

  /// Leading icon.
  final IconData icon;

  /// Entry label.
  final String label;

  /// Whether this is the active entry.
  final bool selected;

  /// Tap callback.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = selected ? c.accent : c.onSurface;
    final radius = BorderRadius.circular(Tokens.radiusField);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected
            ? c.accent.withValues(alpha: Tokens.tintAlpha)
            : Tokens.transparent,
        borderRadius: radius,
        child: InkWell(
          key: itemKey,
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Tokens.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tokens.space12),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: Tokens.space12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall!
                          .copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
