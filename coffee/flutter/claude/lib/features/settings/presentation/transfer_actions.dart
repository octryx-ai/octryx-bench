import 'package:material_ui/material_ui.dart';

import '../../../app/app_data.dart';
import '../../../app/app_services.dart';
import '../../../core/files/save_outcome.dart';
import '../../../core/widgets/banner_severity.dart';
import '../../../l10n/app_localizations.dart';
import '../../transfer/domain/import_error.dart';
import '../../transfer/domain/import_exception.dart';
import 'export_ready_dialog.dart';
import 'transfer_message.dart';

/// Export, import and delete-all with their localized result messages.
class TransferActions {
  /// Creates the actions on [data] using [services] and the texts of [l].
  const TransferActions({
    required this.data,
    required this.services,
    required this.l,
  });

  /// The app data to export from and import into.
  final AppData data;

  /// File transfer of the platform.
  final AppServices services;

  /// Localized texts.
  final AppLocalizations l;

  /// Exports the data: a browser download, or the clipboard plus a dialog on
  /// platforms without download.
  Future<List<TransferMessage>> export(BuildContext context) async {
    final name = data.exportFileName;
    final json = data.exportJson();
    final outcome = await services.transfer.save(name, json);
    if (outcome == SaveOutcome.copied && context.mounted) {
      await ExportReadyDialog.show(context, fileName: name, json: json);
      return const [];
    }
    final text = outcome == SaveOutcome.shared
        ? l.exportShared(name)
        : l.exportDownloaded(name);
    return [TransferMessage(BannerSeverity.info, text)];
  }

  /// Imports [text]; on an error nothing changes and the error is reported.
  Future<List<TransferMessage>> importText(String text) async {
    try {
      final result = await data.importJson(text);
      return [
        TransferMessage(
          BannerSeverity.info,
          l.importResultImported(result.imported),
        ),
        if (result.skipped > 0)
          TransferMessage(
            BannerSeverity.warning,
            l.importResultSkipped(result.skipped),
          ),
      ];
    } on ImportException catch (e) {
      return [
        TransferMessage(
          BannerSeverity.error,
          e.error == ImportError.unsupportedVersion
              ? l.importUnsupported
              : l.importInvalid,
        ),
      ];
    }
  }

  /// Deletes all data.
  Future<List<TransferMessage>> deleteAll() async {
    await data.clearAll();
    return [TransferMessage(BannerSeverity.info, l.deleteAllDone)];
  }
}
