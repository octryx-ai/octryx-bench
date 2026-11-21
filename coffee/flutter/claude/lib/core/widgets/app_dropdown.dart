import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Dropdown with label on top, styled like [AppField]. Options are given as
/// value to label; a null value is a valid option (e.g. "none").
class AppDropdown<T> extends StatelessWidget {
  /// Creates the dropdown.
  const AppDropdown({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Label above the field.
  final String label;

  /// Option value to visible label, in display order.
  final Map<T?, String> options;

  /// Selected value.
  final T? value;

  /// Called with the chosen value.
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Tokens.radiusField),
      borderSide: BorderSide(color: c.border, width: Tokens.borderWidth),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelLarge),
        const SizedBox(height: Tokens.space4),
        DropdownButtonFormField<T?>(
          // A new key per value lets a changed [value] reach the form field.
          key: ValueKey(value),
          initialValue: value,
          isExpanded: true,
          style: text.bodyLarge,
          dropdownColor: c.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.surface,
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
          items: [
            for (final e in options.entries)
              DropdownMenuItem<T?>(
                value: e.key,
                child: Text(
                  e.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
