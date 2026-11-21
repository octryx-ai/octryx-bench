import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/forms/name_input.dart';
import '../../../core/forms/number_input.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_field.dart';
import '../../../core/widgets/form_page.dart';
import '../domain/machine.dart';

/// Form to add a machine, or to edit the one with [machineId].
class MachineFormScreen extends StatefulWidget {
  /// Creates the form.
  const MachineFormScreen({this.machineId, super.key});

  /// Id of the machine to edit; null adds a new one.
  final String? machineId;

  @override
  State<MachineFormScreen> createState() => _MachineFormScreenState();
}

class _MachineFormScreenState extends State<MachineFormScreen> {
  static const _minTemp = 60.0;
  static const _maxTemp = 110.0;
  static const _maxPreinfusion = 60.0;
  static const _maxProfileLength = 200;

  final _name = TextEditingController();
  final _temp = TextEditingController();
  final _pre = TextEditingController();
  final _profile = TextEditingController();
  String? _waterId;
  Machine? _editing;
  Map<String, String> _errors = {};
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in [_name, _temp, _pre, _profile]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = widget.machineId;
    if (_loaded || id == null) return;
    _loaded = true;
    final m = AppScope.of(context).machineById(id);
    if (m == null) return;
    _editing = m;
    _name.text = m.name;
    _temp.text = AppFormat.plain(m.brewTempC);
    _pre.text = AppFormat.plain(m.preinfusionS);
    _profile.text = m.pressureProfile;
    _waterId = m.defaultWaterProfileId;
  }

  Future<void> _save() async {
    final l = context.l10n;
    final data = AppScope.of(context);
    final navigator = Navigator.of(context);
    final errors = <String, String>{};
    final name = nameError(l, _name.text);
    if (name != null) errors['name'] = name;
    final temp = NumberInput.check(l, _temp.text, min: _minTemp, max: _maxTemp);
    final pre = NumberInput.check(l, _pre.text, min: 0, max: _maxPreinfusion);
    if (temp.error != null) errors['temp'] = temp.error!;
    if (pre.error != null) errors['pre'] = pre.error!;
    if (_profile.text.trim().length > _maxProfileLength) {
      errors['profile'] = l.tooLong(_maxProfileLength);
    }
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    final editing = _editing;
    if (editing == null) {
      await data.addMachine(
        name: _name.text.trim(),
        brewTempC: temp.value!,
        preinfusionS: pre.value!,
        pressureProfile: _profile.text.trim(),
        defaultWaterProfileId: _waterId,
      );
    } else {
      await data.updateMachine(
        editing.copyWith(
          name: _name.text.trim(),
          brewTempC: temp.value,
          preinfusionS: pre.value,
          pressureProfile: _profile.text.trim(),
          defaultWaterProfileId: _waterId,
          clearDefaultWaterProfile: _waterId == null,
        ),
      );
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = AppScope.of(context);
    const gap = SizedBox(height: Tokens.space16);
    const decimal = TextInputType.numberWithOptions(decimal: true);
    final waters = {
      null: l.noDefaultWater,
      for (final w in data.waterProfiles) w.id: w.name,
    };
    return FormPage(
      title: _editing == null ? l.machineForm : l.machineEditTitle,
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
          key: const Key('field-temp'),
          label: l.brewTemp,
          controller: _temp,
          unit: l.unitCelsius,
          keyboardType: decimal,
          errorText: _errors['temp'],
        ),
        gap,
        AppField(
          key: const Key('field-pre'),
          label: l.preinfusion,
          controller: _pre,
          unit: l.unitS,
          keyboardType: decimal,
          errorText: _errors['pre'],
        ),
        gap,
        AppField(
          key: const Key('field-profile'),
          label: l.pressureProfile,
          controller: _profile,
          errorText: _errors['profile'],
        ),
        gap,
        AppDropdown<String>(
          key: const Key('field-water'),
          label: l.defaultWater,
          options: waters,
          value: waters.containsKey(_waterId) ? _waterId : null,
          onChanged: (v) => setState(() => _waterId = v),
        ),
      ],
    );
  }
}
