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
import '../domain/finer_direction.dart';
import '../domain/grinder.dart';
import 'grind_setting_error.dart';

/// Form to add a grinder, or to edit the one with [grinderId].
class GrinderFormScreen extends StatefulWidget {
  /// Creates the form.
  const GrinderFormScreen({this.grinderId, super.key});

  /// Id of the grinder to edit; null adds a new one.
  final String? grinderId;

  @override
  State<GrinderFormScreen> createState() => _GrinderFormScreenState();
}

class _GrinderFormScreenState extends State<GrinderFormScreen> {
  static const _maxScale = 1000.0;
  static const _maxDeadSpace = 100.0;

  final _name = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  final _step = TextEditingController();
  final _dead = TextEditingController();
  final _check = TextEditingController();
  FinerDirection _direction = FinerDirection.down;
  Grinder? _editing;
  Map<String, String> _errors = {};
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in [_name, _min, _max, _step, _dead, _check]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = widget.grinderId;
    if (_loaded || id == null) return;
    _loaded = true;
    final g = AppScope.of(context).grinderById(id);
    if (g == null) return;
    _editing = g;
    _name.text = g.name;
    _min.text = AppFormat.plain(g.scaleMin);
    _max.text = AppFormat.plain(g.scaleMax);
    _step.text = AppFormat.plain(g.scaleStep);
    _dead.text = AppFormat.plain(g.deadSpaceG);
    _direction = g.finerDirection;
  }

  /// Validates every field; returns the errors by field key.
  Map<String, String> _validate() {
    final l = context.l10n;
    final errors = <String, String>{};
    final name = nameError(l, _name.text);
    if (name != null) errors['name'] = name;
    final min = NumberInput.check(l, _min.text, min: 0, max: _maxScale);
    final max = NumberInput.check(l, _max.text, min: 0, max: _maxScale);
    final step = NumberInput.check(l, _step.text, min: 0, max: _maxScale);
    final dead = NumberInput.check(l, _dead.text, min: 0, max: _maxDeadSpace);
    if (min.error != null) errors['min'] = min.error!;
    if (max.error != null) errors['max'] = max.error!;
    if (dead.error != null) errors['dead'] = dead.error!;
    if (step.error != null) {
      errors['step'] = step.error!;
    } else if (step.value! <= 0) {
      errors['step'] = l.stepPositive;
    }
    final lo = min.value;
    final hi = max.value;
    if (lo != null && hi != null && hi <= lo) {
      errors['max'] = l.scaleMaxAboveMin;
    }
    return errors;
  }

  Future<void> _save() async {
    final errors = _validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    final data = AppScope.of(context);
    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    final min = AppFormat.parse(_min.text)!;
    final max = AppFormat.parse(_max.text)!;
    final step = AppFormat.parse(_step.text)!;
    final dead = AppFormat.parse(_dead.text)!;
    final editing = _editing;
    if (editing == null) {
      await data.addGrinder(
        name: name,
        scaleMin: min,
        scaleMax: max,
        scaleStep: step,
        finerDirection: _direction,
        deadSpaceG: dead,
      );
    } else {
      await data.updateGrinder(
        editing.copyWith(
          name: name,
          scaleMin: min,
          scaleMax: max,
          scaleStep: step,
          finerDirection: _direction,
          deadSpaceG: dead,
        ),
      );
    }
    navigator.pop();
  }

  /// Error of the test grind setting against the scale typed so far.
  String? _checkError() {
    final l = context.l10n;
    final text = _check.text;
    if (text.trim().isEmpty) return null;
    final value = AppFormat.parse(text);
    final min = AppFormat.parse(_min.text);
    final max = AppFormat.parse(_max.text);
    final step = AppFormat.parse(_step.text);
    if (value == null) return l.enterNumber;
    if (min == null || max == null || step == null) return null;
    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final draft = Grinder(
      id: '',
      createdAt: epoch,
      updatedAt: epoch,
      name: _name.text,
      scaleMin: min,
      scaleMax: max,
      scaleStep: step,
      finerDirection: _direction,
      deadSpaceG: 0,
    );
    return grindSettingErrorText(l, draft, value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    const gap = SizedBox(height: Tokens.space16);
    AppField field(
      String key,
      String label,
      TextEditingController controller, {
      String? unit,
      bool number = true,
    }) => AppField(
      key: Key('field-$key'),
      label: label,
      controller: controller,
      unit: unit,
      errorText: _errors[key],
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      onChanged: (_) => setState(() {}),
    );
    return FormPage(
      title: _editing == null ? l.grinderForm : l.grinderEditTitle,
      onSave: _save,
      children: [
        field('name', l.fieldName, _name, number: false),
        gap,
        field('min', l.scaleMin, _min),
        gap,
        field('max', l.scaleMax, _max),
        gap,
        field('step', l.scaleStep, _step),
        gap,
        Text(l.finerDirection, style: text.labelLarge),
        const SizedBox(height: Tokens.space4),
        AppChoiceChips<FinerDirection>(
          keyPrefix: 'direction',
          labels: {
            FinerDirection.down: l.finerDown,
            FinerDirection.up: l.finerUp,
          },
          selected: _direction,
          onSelected: (d) => setState(() => _direction = d),
        ),
        gap,
        field('dead', l.deadSpace, _dead, unit: l.unitG),
        gap,
        AppField(
          key: const Key('field-check'),
          label: l.checkGrindSetting,
          controller: _check,
          errorText: _checkError(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
