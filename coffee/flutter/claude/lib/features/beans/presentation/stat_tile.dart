import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';

/// Key figure tile: small label, large value and an optional extra widget.
class StatTile extends StatelessWidget {
  /// Creates the tile.
  const StatTile({
    required this.label,
    required this.value,
    this.extra,
    super.key,
  });

  /// Label above the value.
  final String label;

  /// Value text.
  final String value;

  /// Widget under the value (e.g. a chip).
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: text.labelLarge),
            const SizedBox(height: Tokens.space4),
            Text(value, style: text.headlineSmall),
            if (extra != null) ...[
              const SizedBox(height: Tokens.space8),
              extra!,
            ],
          ],
        ),
      ),
    );
  }
}
