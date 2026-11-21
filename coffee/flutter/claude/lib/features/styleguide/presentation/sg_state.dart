import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';

/// One component in one labelled state; found by `Key('sg-<keyName>')`.
class SgState extends StatelessWidget {
  /// Creates a tile.
  SgState({
    required String keyName,
    required this.label,
    required this.child,
    super.key,
  }) : _tileKey = Key('sg-$keyName');

  final Key _tileKey;

  /// State label.
  final String label;

  /// Component rendered in the state.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Tokens.stateTileWidth),
      child: Padding(
        padding: const EdgeInsets.all(
          Tokens.focusRingGap + Tokens.focusRingWidth,
        ),
        child: Column(
          key: _tileKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Tokens.space8),
            child,
          ],
        ),
      ),
    );
  }
}
