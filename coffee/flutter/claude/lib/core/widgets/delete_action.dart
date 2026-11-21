import 'package:material_ui/material_ui.dart';

import '../l10n_context.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Delete icon button with a Semantics label naming the record.
class DeleteAction extends StatelessWidget {
  /// Creates the action for the record called [name].
  const DeleteAction({required this.name, required this.onDelete, super.key});

  /// Name of the record, used in the accessible label.
  final String name;

  /// Called on tap.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.deleteNamed(name);
    return IconButton(
      key: const Key('action-delete'),
      tooltip: label,
      constraints: const BoxConstraints(
        minWidth: Tokens.touchTarget,
        minHeight: Tokens.touchTarget,
      ),
      icon: Semantics(
        label: label,
        child: Icon(Icons.delete_outline, color: AppColors.of(context).error),
      ),
      onPressed: onDelete,
    );
  }
}
