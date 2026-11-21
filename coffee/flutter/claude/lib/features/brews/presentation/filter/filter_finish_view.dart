import 'package:material_ui/material_ui.dart';

import '../../../../app/app_data.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/format/app_format.dart';
import '../../../../core/l10n_context.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/app_banner.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/banner_severity.dart';
import '../../../../core/widgets/form_page.dart';
import '../../domain/brew_exception.dart';
import '../../domain/brew_validation.dart';
import '../../domain/taste.dart';
import '../brew_form_slot.dart';
import '../brew_format.dart';
import '../rating_stars.dart';
import '../taste_chips.dart';
import 'filter_plan.dart';

/// Finish phase of the guided filter: drawdown time (prefilled from the
/// timer), taste and rating. "Save" logs the brew and opens its detail.
class FilterFinishView extends StatefulWidget {
  /// Creates the view for [plan]; [elapsedS] prefills the drawdown time.
  const FilterFinishView({
    required this.plan,
    required this.elapsedS,
    super.key,
  });

  /// The brew to save.
  final FilterPlan plan;

  /// Seconds the timer ran; 0 leaves the field empty.
  final int elapsedS;

  @override
  State<FilterFinishView> createState() => _FilterFinishViewState();
}

class _FilterFinishViewState extends State<FilterFinishView> {
  late final TextEditingController _drawdown = TextEditingController(
    text: widget.elapsedS > 0 ? '${widget.elapsedS}' : '',
  );
  Taste? _taste;
  int? _rating;
  String? _error;
  String? _stockError;

  @override
  void initState() {
    super.initState();
    _drawdown.addListener(() {
      if (_error != null) setState(() => _error = null);
    });
  }

  @override
  void dispose() {
    _drawdown.dispose();
    super.dispose();
  }

  int? get _seconds {
    final v = AppFormat.parse(_drawdown.text);
    if (v == null) return _drawdown.text.trim().isEmpty ? null : 0;
    return v == v.roundToDouble() ? v.toInt() : 0;
  }

  Future<void> _save(AppData data) async {
    final l = context.l10n;
    final navigator = Navigator.of(context);
    final seconds = _seconds;
    if (BrewValidation.validateDrawdown(seconds) != null) {
      setState(() => _error = l.rangeError('1', '600'));
      return;
    }
    final plan = widget.plan;
    try {
      final brew = await data.addBrew(
        method: plan.method,
        grinderId: plan.grinder.id,
        packId: plan.pack.id,
        grindSetting: plan.grindSetting,
        doseG: plan.recipe.doseG,
        waterTotalG: plan.recipe.waterG,
        bloomG: plan.recipe.bloomG,
        pours: plan.recipe.pours,
        drawdownS: seconds,
        waterProfileId: plan.waterProfileId,
        taste: _taste,
        rating: _rating,
      );
      navigator.pushReplacementNamed(AppRoutes.brewDetail, arguments: brew.id);
    } on BrewException catch (e) {
      if (e.failure != BrewFailure.notEnoughBeans) return;
      setState(
        () => _stockError = l.notEnoughBeans(
          BrewFormat.stockGrams(e.remainingG ?? 0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = AppScope.of(context);
    final stock = _stockError;
    return FormPage(
      title: l.filterFinishTitle,
      onSave: () => _save(data),
      children: [
        if (stock != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.space16),
            child: AppBanner(
              key: const Key('hint-not-enough-beans'),
              severity: BannerSeverity.error,
              message: stock,
            ),
          ),
        BrewFormSlot(
          AppField(
            key: const Key('field-drawdown'),
            label: l.filterDrawdownField,
            controller: _drawdown,
            unit: l.unitS,
            keyboardType: TextInputType.number,
            errorText: _error,
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
      ],
    );
  }
}
