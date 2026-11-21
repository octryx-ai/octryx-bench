import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';

/// One form row: its own semantics container (so neighbours do not merge in
/// the web semantics tree) followed by a 16 dp gap.
class BrewFormSlot extends StatelessWidget {
  /// Wraps [child].
  const BrewFormSlot(this.child, {super.key});

  /// Row content.
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Tokens.space16),
    child: Semantics(container: true, child: child),
  );
}
