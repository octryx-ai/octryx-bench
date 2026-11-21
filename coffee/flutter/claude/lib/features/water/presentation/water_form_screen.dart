import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/forms/name_input.dart';
import '../../../core/forms/number_input.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_choice_chips.dart';
import '../../../core/widgets/app_field.dart';
import '../../../core/widgets/form_page.dart';
import '../../settings/domain/hardness_unit.dart';
import '../domain/water_parameter.dart';
import '../domain/water_profile.dart';
import 'water_format.dart';

/// Form to add a water profile, or to edit the one with [profileId].
///
/// Hardness is typed in the chosen unit and stored in ppm; the optional
/// measurements may stay empty (not measured).
class WaterFormScreen extends StatefulWidget {
  /// Creates the form.
  const WaterFormScreen({this.profileId, super.key});

  /// Id of the profile to edit; null adds a new one.
  final String? profileId;

  @override
  State<WaterFormScreen> createState() => _WaterFormScreenState();
}

class _WaterFormScreenState extends State<WaterFormScreen> {
  static const _maxHardnessPpm = 1000.0;

  /// Optional parameters with their allowed range (SPEC section 4).
  static const _optional = {
    WaterParameter.alkalinity: (0.0, 500.0),
    WaterParameter.tds: (0.0, 1000.0),
    WaterParameter.ph: (0.0, 14.0),
    WaterParameter.sodium: (0.0, 500.0),
    WaterParameter.chlorine: (0.0, 10.0),
  };

  final _name = TextEditingController();
  final _hardness = TextEditingController();
  final _values = {for (final p in _optional.keys) p: TextEditingController()};
  HardnessUnit? _unit;
  WaterProfile? _editing;
  Map<String, String> _errors = {};
  bool _loaded = false;

  @override
  void dispose() {
    _name.dispose();
    _hardness.dispose();
    for (final c in _values.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final data = AppScope.of(context);
    _unit = data.hardnessUnit;
    final id = widget.profileId;
    final w = id == null ? null : data.waterProfileById(id);
    if (w == null) return;
    _editing = w;
    _name.text = w.name;
    _hardness.text = AppFormat.plain(_unit!.displayValue(w.hardnessPpm));
    for (final e in _values.entries) {
      final v = e.key.valueOf(w);
      e.value.text = v == null ? '' : AppFormat.plain(v);
    }
  }

  /// Switches the hardness unit and converts what was typed.
  void _selectUnit(HardnessUnit next) {
    final typed = AppFormat.parse(_hardness.text);
    final old = _unit!;
    if (typed != null) {
      _hardness.text = AppFormat.plain(next.displayValue(old.toPpm(typed)));
    }
    setState(() => _unit = next);
  }

  Future<void> _save() async {
    final l = context.l10n;
    final data = AppScope.of(context);
    final navigator = Navigator.of(context);
    final unit = _unit!;
    final errors = <String, String>{};
    final name = nameError(l, _name.text);
    if (name != null) errors['name'] = name;
    final hardness = NumberInput.check(
      l,
      _hardness.text,
      min: 0,
      max: _maxHardnessPpm,
      stored: unit.toPpm,
      shownMin: 0,
      shownMax: unit.displayValue(_maxHardnessPpm),
    );
    if (hardness.error != null) errors['hardness'] = hardness.error!;
    final parsed = <WaterParameter, NumberInput>{};
    for (final e in _optional.entries) {
      final r = NumberInput.check(
        l,
        _values[e.key]!.text,
        min: e.value.$1,
        max: e.value.$2,
        required: false,
      );
      parsed[e.key] = r;
      if (r.error != null) errors[e.key.name] = r.error!;
    }
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    final ppm = unit.toPpm(hardness.value!);
    double? v(WaterParameter p) => parsed[p]!.value;
    final editing = _editing;
    if (editing == null) {
      await data.addWaterProfile(
        name: _name.text.trim(),
        hardnessPpm: ppm,
        alkalinityPpm: v(WaterParameter.alkalinity),
        tdsPpm: v(WaterParameter.tds),
        ph: v(WaterParameter.ph),
        sodiumMgL: v(WaterParameter.sodium),
        chlorineMgL: v(WaterParameter.chlorine),
      );
    } else {
      await data.updateWaterProfile(
        editing.copyWith(
          name: _name.text.trim(),
          hardnessPpm: ppm,
          alkalinityPpm: v(WaterParameter.alkalinity),
          tdsPpm: v(WaterParameter.tds),
          ph: v(WaterParameter.ph),
          sodiumMgL: v(WaterParameter.sodium),
          chlorineMgL: v(WaterParameter.chlorine),
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
    final unit = _unit ?? HardnessUnit.fH;
    return FormPage(
      title: _editing == null ? l.waterForm : l.waterEditTitle,
      onSave: _save,
      children: [
        AppField(
          key: const Key('field-name'),
          label: l.fieldName,
          controller: _name,
          errorText: _errors['name'],
        ),
        gap,
        Text(l.hardnessUnitLabel, style: text.labelLarge),
        const SizedBox(height: Tokens.space4),
        AppChoiceChips<HardnessUnit>(
          keyPrefix: 'unit',
          labels: {
            for (final u in HardnessUnit.values)
              u: WaterFormat.hardnessUnit(l, u),
          },
          selected: unit,
          onSelected: _selectUnit,
        ),
        const SizedBox(height: Tokens.space8),
        AppField(
          key: const Key('field-hardness'),
          label: l.hardnessRequired,
          controller: _hardness,
          unit: WaterFormat.hardnessUnit(l, unit),
          keyboardType: decimal,
          errorText: _errors['hardness'],
        ),
        for (final p in _optional.keys) ...[
          gap,
          AppField(
            key: Key('field-${p.name}'),
            label: WaterFormat.label(l, p),
            controller: _values[p],
            unit: WaterFormat.unit(l, p).isEmpty
                ? null
                : WaterFormat.unit(l, p),
            keyboardType: decimal,
            errorText: _errors[p.name],
          ),
        ],
      ],
    );
  }
}
