import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'focus_ring.dart';
import 'visual_state.dart';

/// Text field with label on top, unit as suffix, focus ring and an error line.
class AppField extends StatefulWidget {
  /// Creates a field.
  const AppField({
    required this.label,
    this.controller,
    this.unit,
    this.suffix,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
    this.forcedState,
    super.key,
  });

  /// Label above the field.
  final String label;

  /// Optional text controller.
  final TextEditingController? controller;

  /// Unit shown as suffix inside the field.
  final String? unit;

  /// Widget shown as suffix instead of [unit] (e.g. an icon button).
  final Widget? suffix;

  /// Error text; shown as a red line under the field.
  final String? errorText;

  /// Whether the field accepts input.
  final bool enabled;

  /// Keyboard type, e.g. decimal numbers.
  final TextInputType? keyboardType;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Renders the focus ring statically (style guide).
  final VisualState? forcedState;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final error = widget.errorText;
    final radius = BorderRadius.circular(Tokens.radiusField);
    final borderColor = error == null ? c.border : c.error;
    OutlineInputBorder border(double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: width),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: text.labelLarge),
        const SizedBox(height: Tokens.space4),
        FocusRing(
          focused: _focus || widget.forcedState == VisualState.focus,
          radius: Tokens.radiusField,
          child: Focus(
            onFocusChange: (v) => setState(() => _focus = v),
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              style: text.bodyLarge,
              decoration: InputDecoration(
                filled: true,
                hoverColor: Tokens.transparent,
                fillColor: widget.enabled
                    ? c.surface
                    : c.onSurface.withValues(alpha: Tokens.tintAlpha),
                suffixIcon:
                    widget.suffix ??
                    (widget.unit == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(
                              right: Tokens.space16,
                            ),
                            child: Center(
                              widthFactor: 1,
                              child: Text(widget.unit!, style: text.bodyMedium),
                            ),
                          )),
                suffixIconConstraints: const BoxConstraints(),
                border: border(Tokens.borderWidth),
                enabledBorder: border(Tokens.borderWidth),
                focusedBorder: border(Tokens.borderWidth),
                disabledBorder: border(Tokens.borderWidth),
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: Tokens.space4),
            child: Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: Tokens.fontSize16,
                    color: c.error,
                  ),
                  const SizedBox(width: Tokens.space4),
                  Expanded(
                    child: Text(
                      error,
                      style: text.bodySmall!.copyWith(color: c.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
