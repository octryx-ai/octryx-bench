import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';

/// Confirmation "Delete all data?" with Cancel and Delete.
abstract final class DeleteAllDialog {
  /// Shows the dialog; true if the user confirmed.
  static Future<bool> confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l = context.l10n;
        return AlertDialog(
          title: Text(l.deleteAllTitle),
          content: Text(l.deleteAllBody),
          actions: [
            TextButton(
              key: const Key('delete-all-cancel'),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.cancel),
            ),
            TextButton(
              key: const Key('delete-all-confirm'),
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.of(context).error,
              ),
              child: Text(l.deleteAllConfirm),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }
}
