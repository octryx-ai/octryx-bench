import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_format.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_field.dart';

/// Roast-date field: typed text (shown format or ISO `yyyy-MM-dd`) plus a
/// calendar button that opens the date picker.
class RoastDateField extends StatelessWidget {
  /// Creates the field; [today] is the latest selectable day.
  const RoastDateField({
    required this.controller,
    required this.today,
    this.errorText,
    super.key,
  });

  /// Years back the picker reaches.
  static const int pickerYears = 10;

  /// Controller of the text.
  final TextEditingController controller;

  /// Today (date-only); later dates cannot be picked.
  final DateTime today;

  /// Error line.
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final format = AppFormat.of(context);
    final typed = AppFormat.parseDate(controller.text);
    final last = DateTime(today.year, today.month, today.day);
    final initial = typed == null || typed.isAfter(today)
        ? last
        : DateTime(typed.year, typed.month, typed.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(today.year - pickerYears),
      lastDate: last,
    );
    if (picked != null) controller.text = format.date(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppField(
      label: l.fieldRoastDate,
      controller: controller,
      errorText: errorText,
      keyboardType: TextInputType.datetime,
      suffix: IconButton(
        key: const Key('roast-date-picker'),
        tooltip: l.pickDate,
        constraints: const BoxConstraints(
          minWidth: Tokens.touchTarget,
          minHeight: Tokens.touchTarget,
        ),
        icon: Semantics(
          label: l.pickDate,
          child: Icon(
            Icons.calendar_today,
            color: AppColors.of(context).accent,
          ),
        ),
        onPressed: () => _pick(context),
      ),
    );
  }
}
