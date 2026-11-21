import 'package:material_ui/material_ui.dart';

import '../../../../app/app_data.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/format/app_format.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/app_banner.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/banner_severity.dart';
import '../../../../core/widgets/form_page.dart';
import '../../../equipment/domain/grinder_scale.dart';
import '../../../equipment/presentation/grind_setting_error.dart';
import '../../domain/brew_method.dart';
import '../../domain/brew_validation.dart';
import '../brew_form_slot.dart';
import '../brew_format.dart';
import '../brew_hints.dart';
import '../grind_stepper.dart';
import 'filter_method_field.dart';
import 'filter_pack_options.dart';
import 'filter_plan.dart';
import 'filter_prefill.dart';
import 'filter_ratio_field.dart';

/// Setup phase of the guided filter: method, grinder, grind setting, pack,
/// water, dose and ratio. "Start" hands a [FilterPlan] to the focus mode.
class FilterSetupView extends StatefulWidget {
  /// Creates the setup; [sourceBrewId] prefills it ("Next try").
  const FilterSetupView({required this.onStart, this.sourceBrewId, super.key});

  /// Brew whose values prefill the setup, or null.
  final String? sourceBrewId;

  /// Called with the plan when the inputs are valid.
  final ValueChanged<FilterPlan> onStart;

  @override
  State<FilterSetupView> createState() => _FilterSetupViewState();
}

class _FilterSetupViewState extends State<FilterSetupView> {
  final _grind = TextEditingController();
  final _dose = TextEditingController();
  late BrewMethod _method;
  late double _ratio;
  String? _grinderId;
  String? _packId;
  String? _waterId;
  bool _loaded = false;
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _dose.addListener(
      () => setState(() => _errors = {..._errors}..remove('dose')),
    );
    _grind.addListener(
      () => setState(() => _errors = {..._errors}..remove('grind')),
    );
  }

  @override
  void dispose() {
    _grind.dispose();
    _dose.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final data = AppScope.of(context);
    final id = widget.sourceBrewId;
    final prefill = FilterPrefill(data, id == null ? null : data.brewById(id));
    _method = prefill.method;
    _ratio = prefill.ratio;
    _grinderId = prefill.grinderId;
    _packId = prefill.packId;
    _waterId = prefill.waterId;
    _dose.text = AppFormat.plain(prefill.dose);
    final grinder = _grinderId == null ? null : data.grinderById(_grinderId!);
    final grind = prefill.grind ?? GrinderScale.initial(grinder);
    _grind.text = BrewFormat.setting(grind);
  }

  void _pickGrinder(AppData data, String? id) {
    final grinder = id == null ? null : data.grinderById(id);
    setState(() {
      _grinderId = id;
      final typed = AppFormat.parse(_grind.text);
      if (grinder != null &&
          (typed == null || GrinderScale.validate(grinder, typed) != null)) {
        _grind.text = BrewFormat.setting(GrinderScale.initial(grinder));
      }
    });
  }

  void _start(AppData data) {
    final l = context.l10n;
    final grinder = _grinderId == null ? null : data.grinderById(_grinderId!);
    final pack = _packId == null ? null : data.packById(_packId!);
    if (grinder == null || pack == null) return;
    final dose = AppFormat.parse(_dose.text);
    final setting = AppFormat.parse(_grind.text);
    final doseError = BrewValidation.validateDose(dose);
    final grindError = setting == null
        ? l.grindSettingNotOnScale(AppFormat.plain(grinder.scaleStep))
        : grindSettingErrorText(l, grinder, setting);
    final errors = {
      'dose': ?(doseError == null ? null : l.rangeError('5', '40')),
      'grind': ?grindError,
    };
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    widget.onStart(
      FilterPlan(
        method: _method,
        grinder: grinder,
        pack: pack,
        grindSetting: setting!,
        recipe: data.filterRecipes.recipe(doseG: dose!, ratio: _ratio),
        waterProfileId: _waterId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = AppScope.of(context);
    final calc = data.filterRecipes;
    final grinder = _grinderId == null ? null : data.grinderById(_grinderId!);
    final suggestions = data.filterPackSuggestions();
    final packOptions = FilterPackOptions.labels(context, suggestions);
    final packId = packOptions.containsKey(_packId)
        ? _packId
        : suggestions.firstOrNull?.pack.id;
    _packId = packId;
    final dose = AppFormat.parse(_dose.text);
    final doseOk = BrewValidation.validateDose(dose) == null;
    final waters = {
      null: l.noDefaultWater,
      for (final w in data.waterProfiles) w.id: w.name,
    };
    final canStart = packId != null && grinder != null;
    return FormPage(
      title: l.filterGuided,
      saveLabel: l.filterStart,
      onSave: canStart ? () => _start(data) : null,
      children: [
        BrewHints(
          noGrinder: data.grinders.isEmpty,
          noMachine: false,
          noPack: false,
          advice: null,
        ),
        if (suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.space16),
            child: AppBanner(
              key: const Key('hint-no-filter-pack'),
              severity: BannerSeverity.warning,
              message: l.filterNoPack,
            ),
          ),
        BrewFormSlot(
          FilterMethodField(
            calculator: calc,
            method: _method,
            onChanged: (m) => setState(() => _method = m),
          ),
        ),
        BrewFormSlot(
          AppDropdown<String>(
            key: const Key('field-grinder'),
            label: l.brewGrinder,
            options: {for (final g in data.grinders) g.id: g.name},
            value: _grinderId,
            onChanged: (id) => _pickGrinder(data, id),
          ),
        ),
        if (grinder != null)
          BrewFormSlot(
            GrindStepper(
              grinder: grinder,
              controller: _grind,
              errorText: _errors['grind'],
            ),
          ),
        BrewFormSlot(
          AppDropdown<String>(
            key: const Key('field-pack'),
            label: l.brewPack,
            options: packOptions,
            value: packId,
            onChanged: (id) => setState(() => _packId = id),
          ),
        ),
        BrewFormSlot(
          AppDropdown<String>(
            key: const Key('field-water'),
            label: l.brewWater,
            options: waters,
            value: waters.containsKey(_waterId) ? _waterId : null,
            onChanged: (id) => setState(() => _waterId = id),
          ),
        ),
        BrewFormSlot(
          AppField(
            key: const Key('field-dose'),
            label: l.brewDose,
            controller: _dose,
            unit: l.unitG,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _errors['dose'],
          ),
        ),
        BrewFormSlot(
          FilterRatioField(
            calculator: calc,
            ratio: _ratio,
            waterG: doseOk
                ? calc.recipe(doseG: dose!, ratio: _ratio).waterG
                : null,
            onChanged: (r) => setState(() => _ratio = r),
          ),
        ),
      ],
    );
  }
}
