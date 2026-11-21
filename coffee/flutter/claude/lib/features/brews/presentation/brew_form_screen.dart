import 'package:material_ui/material_ui.dart';

import '../../../app/app_data.dart';
import '../../../app/app_scope.dart';
import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_field.dart';
import '../../../core/widgets/form_page.dart';
import '../../equipment/domain/grinder_scale.dart';
import '../domain/brew_exception.dart';
import '../domain/brew_method.dart';
import '../domain/taste.dart';
import 'brew_amount_fields.dart';
import 'brew_form_input.dart';
import 'brew_form_slot.dart';
import 'brew_prefill.dart';
import 'brew_format.dart';
import 'brew_hints.dart';
import 'brew_method_field.dart';
import 'brew_pickers.dart';
import 'grind_stepper.dart';
import 'rating_stars.dart';
import 'shot_timer_field.dart';
import 'taste_chips.dart';

/// Form to log an espresso brew. With [sourceBrewId] the values of that brew
/// are taken over ("Next try"): the grind setting follows its recommendation
/// and taste, rating and shot time start empty.
class BrewFormScreen extends StatefulWidget {
  /// Creates the form.
  const BrewFormScreen({this.sourceBrewId, super.key});

  /// Brew whose values prefill the form, or null for an empty form.
  final String? sourceBrewId;

  @override
  State<BrewFormScreen> createState() => _BrewFormScreenState();
}

class _BrewFormScreenState extends State<BrewFormScreen> {
  final _grind = TextEditingController();
  final _dose = TextEditingController();
  final _purge = TextEditingController();
  final _yield = TextEditingController();
  final _shot = TextEditingController();
  final _note = TextEditingController();
  late final _tracked = {
    'grind': _grind,
    'dose': _dose,
    'yield': _yield,
    'purge': _purge,
    'shot': _shot,
  };
  String? _machineId;
  String? _grinderId;
  String? _packId;
  String? _waterId;
  Taste? _taste;
  int? _rating;
  bool _purgeEdited = false;
  bool _waterEdited = false;
  bool _loaded = false;
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    // A field's error line goes away as soon as its text changes.
    for (final e in _tracked.entries) {
      e.value.addListener(() {
        if (_errors.containsKey(e.key)) {
          setState(() => _errors = {..._errors}..remove(e.key));
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in [..._tracked.values, _note]) {
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
    final id = widget.sourceBrewId;
    final source = id == null ? null : data.brewById(id);
    final prefill = BrewPrefill(data, source);
    _machineId = prefill.machineId;
    _grinderId = prefill.grinderId;
    _packId = prefill.packId;
    if (source == null) {
      final grinder = _grinderId == null ? null : data.grinderById(_grinderId!);
      _grind.text = BrewFormat.setting(GrinderScale.initial(grinder));
      _waterId = BrewPrefill.machineWater(data, _machineId);
      _syncPurge(data);
      return;
    }
    _grind.text = prefill.grind!;
    _dose.text = prefill.dose!;
    _purge.text = prefill.purge!;
    _yield.text = prefill.yieldG ?? '';
    _purgeEdited = true;
    _waterId =
        source.waterProfileId ?? BrewPrefill.machineWater(data, _machineId);
    _waterEdited = true;
  }

  String? get _beanId {
    final id = _packId;
    return id == null ? null : AppScope.of(context).packById(id)?.beanId;
  }

  void _syncPurge(AppData data) {
    if (_purgeEdited) return;
    final g = _grinderId;
    final b = _beanId;
    final advice = g == null || b == null
        ? null
        : data.purgeAdvice(grinderId: g, beanId: b);
    _purge.text = AppFormat.plain(advice?.purgeG ?? 0);
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
      _syncPurge(data);
    });
  }

  void _pickMachine(AppData data, String? id) => setState(() {
    _machineId = id;
    if (!_waterEdited) _waterId = BrewPrefill.machineWater(data, _machineId);
  });

  void _pickPack(AppData data, String? id) => setState(() {
    _packId = id;
    _syncPurge(data);
  });

  Future<void> _save() async {
    final l = context.l10n;
    final data = AppScope.of(context);
    final navigator = Navigator.of(context);
    final grinder = _grinderId == null ? null : data.grinderById(_grinderId!);
    if (grinder == null || _machineId == null || _packId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.brewSelectionMissing)));
      return;
    }
    final input = BrewFormInput(
      grinder: grinder,
      grind: _grind.text,
      dose: _dose.text,
      yieldG: _yield.text,
      purge: _purge.text,
      shot: _shot.text,
    );
    final errors = input.errors(l);
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    try {
      await data.addBrew(
        method: BrewMethod.espresso,
        machineId: _machineId,
        grinderId: grinder.id,
        packId: _packId!,
        grindSetting: input.grind!,
        doseG: input.dose!,
        purgeG: input.purge!,
        yieldG: input.yieldG,
        shotTimeS: input.shot,
        waterProfileId: _waterId,
        taste: _taste,
        rating: _rating,
        note: _note.text.trim(),
      );
    } on BrewException catch (e) {
      if (e.failure != BrewFailure.notEnoughBeans) return;
      setState(
        () => _errors = {
          'dose': l.notEnoughBeans(BrewFormat.stockGrams(e.remainingG ?? 0)),
        },
      );
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = AppScope.of(context);
    final grinder = _grinderId == null ? null : data.grinderById(_grinderId!);
    final beanId = _beanId;
    final advice = _grinderId == null || beanId == null
        ? null
        : data.purgeAdvice(grinderId: _grinderId!, beanId: beanId);
    final waters = {
      null: l.noDefaultWater,
      for (final w in data.waterProfiles) w.id: w.name,
    };
    return FormPage(
      title: l.brewForm,
      onSave: _save,
      children: [
        BrewHints(
          noGrinder: data.grinders.isEmpty,
          noMachine: data.machines.isEmpty,
          noPack: data.packs.isEmpty,
          advice: advice,
        ),
        const BrewMethodField(),
        BrewPickers(
          data: data,
          machineId: _machineId,
          grinderId: _grinderId,
          packId: _packId,
          onMachine: (id) => _pickMachine(data, id),
          onGrinder: (id) => _pickGrinder(data, id),
          onPack: (id) => _pickPack(data, id),
        ),
        const SizedBox(height: Tokens.space16),
        if (grinder != null)
          BrewFormSlot(
            GrindStepper(
              grinder: grinder,
              controller: _grind,
              errorText: _errors['grind'],
            ),
          ),
        BrewAmountFields(
          dose: _dose,
          purge: _purge,
          yieldG: _yield,
          errors: _errors,
          onPurgeEdited: () => _purgeEdited = true,
        ),
        BrewFormSlot(
          ShotTimerField(controller: _shot, errorText: _errors['shot']),
        ),
        BrewFormSlot(
          AppDropdown<String>(
            key: const Key('field-water'),
            label: l.brewWater,
            options: waters,
            value: waters.containsKey(_waterId) ? _waterId : null,
            onChanged: (v) => setState(() {
              _waterId = v;
              _waterEdited = true;
            }),
          ),
        ),
        BrewFormSlot(
          TasteChips(
            taste: _taste,
            onChanged: (t) => setState(() => _taste = t),
          ),
        ),
        BrewFormSlot(
          RatingStars(
            rating: _rating,
            onChanged: (r) => setState(() => _rating = r),
          ),
        ),
        BrewFormSlot(
          AppField(
            key: const Key('field-note'),
            label: l.brewNote,
            controller: _note,
          ),
        ),
      ],
    );
  }
}
