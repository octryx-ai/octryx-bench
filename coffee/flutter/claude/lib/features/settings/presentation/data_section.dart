import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_services.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/outline_action.dart';
import 'delete_all_dialog.dart';
import 'paste_json_dialog.dart';
import 'transfer_actions.dart';
import 'transfer_message.dart';

/// Settings sections Export, Import and "Delete all data" with the result
/// banners of the last action.
class DataSection extends StatefulWidget {
  /// Creates the section.
  const DataSection({super.key});

  @override
  State<DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends State<DataSection> {
  List<TransferMessage> _messages = const [];

  TransferActions get _actions => TransferActions(
    data: AppScope.of(context),
    services: AppServicesScope.of(context),
    l: context.l10n,
  );

  Future<void> _run(Future<List<TransferMessage>> Function() action) async {
    final messages = await action();
    if (mounted) setState(() => _messages = messages);
  }

  Future<void> _importPicked() async {
    final actions = _actions;
    final transfer = AppServicesScope.of(context).transfer;
    final text = transfer.canPick
        ? await transfer.pickText()
        : await PasteJsonDialog.show(context);
    if (text != null) await _run(() => actions.importText(text));
  }

  Future<void> _importPasted() async {
    final actions = _actions;
    final text = await PasteJsonDialog.show(context);
    if (text != null) await _run(() => actions.importText(text));
  }

  Future<void> _deleteAll() async {
    final actions = _actions;
    if (await DeleteAllDialog.confirm(context)) {
      await _run(actions.deleteAll);
    }
  }

  Widget _title(String title, String help) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleMedium),
        const SizedBox(height: Tokens.space4),
        Text(help, style: text.bodyMedium),
        const SizedBox(height: Tokens.space12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final actions = _actions;
    return Column(
      key: const Key('settings-data'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(l.exportData, l.exportHelp),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            key: const Key('settings-export'),
            label: l.exportButton,
            onPressed: () => _run(() => actions.export(context)),
          ),
        ),
        const SizedBox(height: Tokens.space24),
        _title(l.importData, l.importHelp),
        Wrap(
          spacing: Tokens.space12,
          runSpacing: Tokens.space12,
          children: [
            AppButton(
              key: const Key('settings-import'),
              label: l.importButton,
              onPressed: _importPicked,
            ),
            OutlineAction(
              key: const Key('settings-import-paste'),
              label: l.importPasteButton,
              onPressed: _importPasted,
            ),
          ],
        ),
        for (final m in _messages)
          Padding(
            padding: const EdgeInsets.only(top: Tokens.space12),
            child: AppBanner(severity: m.severity, message: m.text),
          ),
        const SizedBox(height: Tokens.space24),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlineAction(
            key: const Key('settings-delete-all'),
            label: l.deleteAllButton,
            color: AppColors.of(context).error,
            onPressed: _deleteAll,
          ),
        ),
      ],
    );
  }
}
