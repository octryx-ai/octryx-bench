import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/format/app_format.dart';
import '../../../core/forms/name_input.dart';
import '../../../core/forms/number_input.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_choice_chips.dart';
import '../../../core/widgets/app_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../equipment/domain/finer_direction.dart';

/// Page 3 of the onboarding: the first grinder (name, scale and dead space),
/// checked with the same rules and messages as the grinder form in Ausrüstung.
class OnboardingGrinderPage extends StatefulWidget {
  /// Creates the page. [createdName] is set once the grinder is saved; then the
  /// form is replaced by its name and nothing is created again.
  const OnboardingGrinderPage({
    required this.onCreated,
    this.createdName,
    super.key,
  });

  /// Name of the grinder saved before, or null.
  final String? createdName;

  /// Called with the name after the grinder has been saved.
  final ValueChanged<String> onCreated;

  @override
  State<OnboardingGrinderPage> createState() => OnboardingGrinderPageState();
}

/// State of [OnboardingGrinderPage]; the onboarding calls [submit] on Weiter.
class OnboardingGrinderPageState extends State<OnboardingGrinderPage> {
  static const _maxScale = 1000.0;
  static const _maxDeadSpace = 100.0;

  final _name = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  final _step = TextEditingController();
  final _dead = TextEditingController();
  FinerDirection _direction = FinerDirection.down;
  Map<String, String> _errors = {};

  @override
  void dispose() {
    for (final c in [_name, _min, _max, _step, _dead]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Saves the grinder when the form is valid. Returns true when the page may
  /// be left: after the save, or when a grinder was saved before.
  Future<bool> submit() async {
    if (widget.createdName != null) return true;
    final errors = _validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return false;
    final name = _name.text.trim();
    await AppScope.of(context).addGrinder(
      name: name,
      scaleMin: AppFormat.parse(_min.text)!,
      scaleMax: AppFormat.parse(_max.text)!,
      scaleStep: AppFormat.parse(_step.text)!,
      finerDirection: _direction,
      deadSpaceG: AppFormat.parse(_dead.text)!,
    );
    widget.onCreated(name);
    return true;
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
    if (step.error != null) {
      errors['step'] = step.error!;
    } else if (step.value! <= 0) {
      errors['step'] = l.stepPositive;
    }
    if (dead.error != null) errors['dead'] = dead.error!;
    final lo = min.value;
    final hi = max.value;
    if (lo != null && hi != null && hi <= lo) {
      errors['max'] = l.scaleMaxAboveMin;
    }
    return errors;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final created = widget.createdName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          label: l.onboardingGrinderTitle,
          child: ExcludeSemantics(
            child: Text(l.onboardingGrinderTitle, style: text.headlineMedium),
          ),
        ),
        const SizedBox(height: Tokens.space12),
        Semantics(
          label: l.onboardingGrinderText,
          child: ExcludeSemantics(
            child: Text(l.onboardingGrinderText, style: text.bodyLarge),
          ),
        ),
        const SizedBox(height: Tokens.space16),
        if (created != null)
          Semantics(
            label: l.onboardingGrinderCreated(created),
            child: ExcludeSemantics(
              child: Text(
                l.onboardingGrinderCreated(created),
                style: text.bodyLarge,
              ),
            ),
          ),
        if (created == null) ..._fields(l, text),
      ],
    );
  }

  /// The same fields, in the same order, as the grinder form in Ausrüstung.
  List<Widget> _fields(AppLocalizations l, TextTheme text) => [
    AppField(label: l.fieldName, controller: _name, errorText: _errors['name']),
    const SizedBox(height: Tokens.space12),
    AppField(label: l.scaleMin, controller: _min, errorText: _errors['min']),
    const SizedBox(height: Tokens.space12),
    AppField(label: l.scaleMax, controller: _max, errorText: _errors['max']),
    const SizedBox(height: Tokens.space12),
    AppField(label: l.scaleStep, controller: _step, errorText: _errors['step']),
    const SizedBox(height: Tokens.space12),
    Text(l.finerDirection, style: text.labelLarge),
    const SizedBox(height: Tokens.space4),
    AppChoiceChips<FinerDirection>(
      keyPrefix: 'direction',
      labels: {FinerDirection.down: l.finerDown, FinerDirection.up: l.finerUp},
      selected: _direction,
      onSelected: (d) => setState(() => _direction = d),
    ),
    const SizedBox(height: Tokens.space12),
    AppField(
      label: l.deadSpace,
      controller: _dead,
      unit: l.unitG,
      errorText: _errors['dead'],
    ),
  ];
}
