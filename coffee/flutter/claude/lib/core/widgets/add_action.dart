import 'package:material_ui/material_ui.dart';

import '../l10n_context.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// "+" icon button in the top bar that pushes [route].
class AddAction extends StatelessWidget {
  /// Creates the action.
  const AddAction({required this.route, this.label, super.key});

  /// Route of the form to open.
  final String route;

  /// Accessible label; defaults to "Add".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = label ?? context.l10n.add;
    return IconButton(
      key: const Key('action-add'),
      tooltip: text,
      icon: Semantics(
        label: text,
        child: Icon(Icons.add, color: AppColors.of(context).onSurface),
      ),
      constraints: const BoxConstraints(
        minWidth: Tokens.touchTarget,
        minHeight: Tokens.touchTarget,
      ),
      onPressed: () => Navigator.of(context).pushNamed(route),
    );
  }
}
