import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';

/// Dialog "Paste JSON": a multi-line field and the Import button. Closes with
/// the entered text, or null when cancelled.
class PasteJsonDialog extends StatefulWidget {
  /// Creates the dialog.
  const PasteJsonDialog({super.key});

  /// Shows the dialog and returns the pasted text, or null.
  static Future<String?> show(BuildContext context) => showDialog<String>(
    context: context,
    builder: (_) => const PasteJsonDialog(),
  );

  @override
  State<PasteJsonDialog> createState() => _PasteJsonDialogState();
}

class _PasteJsonDialogState extends State<PasteJsonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.importPasteButton),
      content: SizedBox(
        width: Tokens.stateTileWidth * 2,
        child: TextField(
          key: const Key('import-json-field'),
          controller: _controller,
          autofocus: true,
          minLines: 6,
          maxLines: 10,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: l.importJsonLabel,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Tokens.radiusField),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          key: const Key('import-json-confirm'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l.importConfirm),
        ),
      ],
    );
  }
}
