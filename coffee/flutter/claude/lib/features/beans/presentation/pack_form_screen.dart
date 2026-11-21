import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/form_page.dart';
import '../domain/pack.dart';
import 'pack_fields.dart';
import 'pack_input.dart';

/// Form to add a pack to the bean [beanId], or to edit the pack [packId].
class PackFormScreen extends StatefulWidget {
  /// Creates the form.
  const PackFormScreen({this.beanId, this.packId, super.key});

  /// Bean a new pack belongs to.
  final String? beanId;

  /// Pack to edit; null adds a new one.
  final String? packId;

  @override
  State<PackFormScreen> createState() => _PackFormScreenState();
}

class _PackFormScreenState extends State<PackFormScreen> {
  final _input = PackInput();
  PackInputResult? _result;
  Pack? _editing;
  bool _loaded = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final data = AppScope.of(context);
    final format = AppFormat.of(context);
    final id = widget.packId;
    final pack = id == null ? null : data.packById(id);
    _editing = pack;
    _input.roastDate.text = format.date(pack?.roastDate ?? data.today);
    if (pack != null) _input.weight.text = AppFormat.plain(pack.sizeG);
  }

  Future<void> _save() async {
    final data = AppScope.of(context);
    final navigator = Navigator.of(context);
    final result = _input.check(
      context.l10n,
      AppFormat.of(context),
      data.today,
    );
    setState(() => _result = result);
    if (!result.isValid) return;
    final editing = _editing;
    if (editing != null) {
      final size = result.sizeG!;
      await data.updatePack(
        editing.copyWith(
          roastDate: result.roastDate,
          sizeG: size,
          remainingG: editing.openedAt == null
              ? size
              : editing.remainingG.clamp(0, size).toDouble(),
        ),
      );
    } else if (widget.beanId != null) {
      await data.addPack(
        beanId: widget.beanId!,
        roastDate: result.roastDate!,
        sizeG: result.sizeG!,
      );
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FormPage(
      title: _editing == null ? l.packForm : l.packEditTitle,
      onSave: _save,
      children: [
        PackFields(
          input: _input,
          today: AppScope.of(context).today,
          result: _result,
        ),
      ],
    );
  }
}
