import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/forms/name_input.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_choice_chips.dart';
import '../../../core/widgets/app_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../beans/domain/bean_kind.dart';
import '../../beans/domain/roast_level.dart';
import '../../beans/presentation/bean_format.dart';

/// Page 4 of the onboarding: the first bean (name, roaster, roast level and
/// kind), checked with the rules of the bean form in Bohnen. The bean gets no
/// pack here; Heute lists it under "Ohne Packung" until a pack is added.
class OnboardingBeanPage extends StatefulWidget {
  /// Creates the page. [createdName] is set once the bean is saved; then the
  /// form is replaced by its name and nothing is created again.
  const OnboardingBeanPage({
    required this.onCreated,
    this.createdName,
    this.grinderName,
    super.key,
  });

  /// Name of the bean saved before, or null.
  final String? createdName;

  /// Name of the grinder saved on page 3, or null; shown above the form.
  final String? grinderName;

  /// Called with the name after the bean has been saved.
  final ValueChanged<String> onCreated;

  @override
  State<OnboardingBeanPage> createState() => OnboardingBeanPageState();
}

/// State of [OnboardingBeanPage]; the onboarding calls [submit] on Weiter.
class OnboardingBeanPageState extends State<OnboardingBeanPage> {
  final _name = TextEditingController();
  final _roaster = TextEditingController();
  RoastLevel _roast = RoastLevel.medium;
  BeanKind _kind = BeanKind.espressoBlend;
  Map<String, String> _errors = {};
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _roaster.dispose();
    super.dispose();
  }

  /// Saves the bean when the form is valid. Returns true when the page may be
  /// left by Los geht's: after the save, or when a bean was saved before. A
  /// second call while the first save is running saves nothing (AC 6).
  Future<bool> submit() async {
    if (widget.createdName != null) return true;
    if (_saving) return false;
    final errors = _validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return false;
    final name = _name.text.trim();
    setState(() => _saving = true);
    try {
      await AppScope.of(context).addBean(
        name: name,
        roaster: _roaster.text.trim(),
        roastLevel: _roast,
        kind: _kind,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return false;
    widget.onCreated(name);
    return true;
  }

  /// Validates name and roaster; returns the errors by field key.
  Map<String, String> _validate() {
    final l = context.l10n;
    final errors = <String, String>{};
    final name = nameError(l, _name.text);
    if (name != null) errors['name'] = name;
    if (_roaster.text.trim().isEmpty) {
      errors['roaster'] = l.onboardingBeanRoasterRequired;
    }
    return errors;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final created = widget.createdName;
    final grinder = widget.grinderName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          label: l.onboardingFinishTitle,
          child: ExcludeSemantics(
            child: Text(l.onboardingFinishTitle, style: text.headlineMedium),
          ),
        ),
        const SizedBox(height: Tokens.space12),
        _line(l.onboardingBeanText, text),
        if (grinder != null) ...[
          const SizedBox(height: Tokens.space12),
          _line(l.onboardingGrinderCreated(grinder), text),
        ],
        const SizedBox(height: Tokens.space16),
        if (created != null)
          _line(l.onboardingBeanCreated(created), text)
        else
          ..._fields(l, text),
      ],
    );
  }

  /// One line of body text as its own semantics node.
  Widget _line(String value, TextTheme text) => Semantics(
    label: value,
    child: ExcludeSemantics(child: Text(value, style: text.bodyLarge)),
  );

  /// The bean fields, in the order of the bean form in Bohnen.
  List<Widget> _fields(AppLocalizations l, TextTheme text) => [
    AppField(label: l.fieldName, controller: _name, errorText: _errors['name']),
    const SizedBox(height: Tokens.space12),
    AppField(
      label: l.fieldRoaster,
      controller: _roaster,
      errorText: _errors['roaster'],
    ),
    const SizedBox(height: Tokens.space12),
    Text(l.fieldRoastLevel, style: text.labelLarge),
    const SizedBox(height: Tokens.space4),
    AppChoiceChips<RoastLevel>(
      keyPrefix: 'onboardingRoast',
      labels: {for (final r in RoastLevel.values) r: BeanFormat.roast(l, r)},
      selected: _roast,
      onSelected: (v) => setState(() => _roast = v),
    ),
    const SizedBox(height: Tokens.space12),
    Text(l.fieldKind, style: text.labelLarge),
    const SizedBox(height: Tokens.space4),
    AppChoiceChips<BeanKind>(
      keyPrefix: 'onboardingKind',
      labels: {for (final k in BeanKind.values) k: BeanFormat.kind(l, k)},
      selected: _kind,
      onSelected: (v) => setState(() => _kind = v),
    ),
  ];
}
