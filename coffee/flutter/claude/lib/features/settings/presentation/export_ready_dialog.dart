import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';

/// Dialog shown where no download is possible: the JSON was copied to the
/// clipboard and is listed here with the name to save it under.
class ExportReadyDialog extends StatelessWidget {
  /// Creates the dialog for [json] to be saved as [fileName].
  const ExportReadyDialog({
    required this.fileName,
    required this.json,
    super.key,
  });

  /// File name to save the text under.
  final String fileName;

  /// The exported JSON text.
  final String json;

  /// Shows the dialog.
  static Future<void> show(
    BuildContext context, {
    required String fileName,
    required String json,
  }) => showDialog<void>(
    context: context,
    builder: (_) => ExportReadyDialog(fileName: fileName, json: json),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.exportReadyTitle),
      content: SizedBox(
        width: Tokens.stateTileWidth * 2,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.exportCopiedBody(fileName)),
              const SizedBox(height: Tokens.space12),
              SelectableText(
                json,
                key: const Key('export-json-text'),
                maxLines: 8,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.close),
        ),
      ],
    );
  }
}
