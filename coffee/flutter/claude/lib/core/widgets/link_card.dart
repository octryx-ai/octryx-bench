import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'app_card.dart';

/// Interactive card that opens a route (list entry with chevron).
class LinkCard extends StatelessWidget {
  /// Creates a link card for [route].
  const LinkCard({
    required this.label,
    required this.icon,
    required this.route,
    super.key,
  });

  /// Card text.
  final String label;

  /// Leading icon.
  final IconData icon;

  /// Route to push on tap.
  final String route;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Tokens.space12),
      child: AppCard(
        key: Key('link-$route'),
        semanticLabel: label,
        onTap: () => Navigator.of(context).pushNamed(route),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Tokens.touchTarget),
          child: Row(
            children: [
              Icon(icon, color: c.accent),
              const SizedBox(width: Tokens.space16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: c.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
