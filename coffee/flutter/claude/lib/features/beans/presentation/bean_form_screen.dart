import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/forms/name_input.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_choice_chips.dart';
import '../../../core/widgets/app_field.dart';
import '../../../core/widgets/form_page.dart';
import '../domain/bean.dart';
import '../domain/bean_field_error.dart';
import '../domain/bean_kind.dart';
import '../domain/bean_validation.dart';
import '../domain/roast_level.dart';
import 'bean_format.dart';
import 'pack_fields.dart';
import 'pack_input.dart';

/// Form to add a bean with its first pack, or to edit the bean [beanId].
class BeanFormScreen extends StatefulWidget {
  /// Creates the form.
  const BeanFormScreen({this.beanId, super.key});

  /// Id of the bean to edit; null adds a new one.
  final String? beanId;

  @override
  State<BeanFormScreen> createState() => _BeanFormScreenState();
}

class _BeanFormScreenState extends State<BeanFormScreen> {
  static const _defaultLeadTimeDays = 3;

  final _name = TextEditingController();
  final _roaster = TextEditingController();
  final _leadTime = TextEditingController(text: '$_defaultLeadTimeDays');
  final _minStock = TextEditingController();
  final _pack = PackInput();
  RoastLevel _roast = RoastLevel.medium;
  BeanKind _kind = BeanKind.espressoBlend;
  Bean? _editing;
  Map<String, String> _errors = {};
  PackInputResult? _packResult;
  bool _loaded = false;

  @override
  void dispose() {
    _name.dispose();
    _roaster.dispose();
    _leadTime.dispose();
    _minStock.dispose();
    _pack.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final data = AppScope.of(context);
    final id = widget.beanId;
    final bean = id == null ? null : data.beanById(id);
    _pack.roastDate.text = AppFormat.of(context).date(data.today);
    if (bean == null) return;
    _editing = bean;
    _name.text = bean.name;
    _roaster.text = bean.roaster;
    _roast = bean.roastLevel;
    _kind = bean.kind;
    _leadTime.text = '${bean.leadTimeDays}';
    final min = bean.minStockG;
    _minStock.text = min == null ? '' : AppFormat.plain(min);
  }

  Future<void> _save() async {
    final l = context.l10n;
    final data = AppScope.of(context);
    final navigator = Navigator.of(context);
    final errors = <String, String>{};
    final name = nameError(l, _name.text);
    if (name != null) errors['name'] = name;
    final lead = AppFormat.parse(_leadTime.text);
    final leadDays = lead != null && lead == lead.roundToDouble()
        ? lead.toInt()
        : null;
    final leadError = BeanValidation.validateLeadTime(leadDays);
    if (leadError != null) errors['leadTime'] = BeanFormat.error(l, leadError);
    final minText = _minStock.text.trim();
    final min = AppFormat.parse(minText);
    final minOk =
        minText.isEmpty ||
        (min != null && BeanValidation.validateMinStock(min) == null);
    if (!minOk) {
      errors['minStock'] = BeanFormat.error(
        l,
        BeanFieldError.minStockOutOfRange,
      );
    }
    final editing = _editing;
    final packResult = editing == null
        ? _pack.check(l, AppFormat.of(context), data.today)
        : null;
    setState(() {
      _errors = errors;
      _packResult = packResult;
    });
    if (errors.isNotEmpty || !(packResult?.isValid ?? true)) return;
    if (editing == null) {
      final bean = await data.addBean(
        name: _name.text.trim(),
        roaster: _roaster.text.trim(),
        roastLevel: _roast,
        kind: _kind,
        minStockG: min,
        leadTimeDays: leadDays!,
      );
      await data.addPack(
        beanId: bean.id,
        roastDate: packResult!.roastDate!,
        sizeG: packResult.sizeG!,
      );
    } else {
      await data.updateBean(
        editing.copyWith(
          name: _name.text.trim(),
          roaster: _roaster.text.trim(),
          roastLevel: _roast,
          kind: _kind,
          minStockG: min,
          clearMinStock: min == null,
          leadTimeDays: leadDays,
        ),
      );
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    const gap = SizedBox(height: Tokens.space16);
    const decimal = TextInputType.numberWithOptions(decimal: true);
    return FormPage(
      title: _editing == null ? l.beanForm : l.beanEditTitle,
      onSave: _save,
      children: [
        AppField(
          key: const Key('field-name'),
          label: l.fieldName,
          controller: _name,
          errorText: _errors['name'],
        ),
        gap,
        AppField(
          key: const Key('field-roaster'),
          label: l.fieldRoaster,
          controller: _roaster,
        ),
        gap,
        Text(l.fieldRoastLevel, style: text.labelLarge),
        const SizedBox(height: Tokens.space4),
        AppChoiceChips<RoastLevel>(
          keyPrefix: 'roast',
          labels: {
            for (final r in RoastLevel.values) r: BeanFormat.roast(l, r),
          },
          selected: _roast,
          onSelected: (v) => setState(() => _roast = v),
        ),
        gap,
        Text(l.fieldKind, style: text.labelLarge),
        const SizedBox(height: Tokens.space4),
        AppChoiceChips<BeanKind>(
          keyPrefix: 'kind',
          labels: {for (final k in BeanKind.values) k: BeanFormat.kind(l, k)},
          selected: _kind,
          onSelected: (v) => setState(() => _kind = v),
        ),
        gap,
        AppField(
          key: const Key('field-leadTime'),
          label: l.fieldLeadTime,
          controller: _leadTime,
          unit: l.unitDays,
          keyboardType: TextInputType.number,
          errorText: _errors['leadTime'],
        ),
        gap,
        AppField(
          key: const Key('field-minStock'),
          label: l.fieldMinStock,
          controller: _minStock,
          unit: l.unitG,
          keyboardType: decimal,
          errorText: _errors['minStock'],
        ),
        if (_editing == null) ...[
          const SizedBox(height: Tokens.space24),
          Text(l.firstPack, style: text.titleMedium),
          gap,
          PackFields(
            input: _pack,
            today: AppScope.of(context).today,
            result: _packResult,
          ),
        ],
      ],
    );
  }
}
