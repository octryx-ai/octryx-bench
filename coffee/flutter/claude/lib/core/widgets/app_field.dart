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
    this.errorText,
    this.enabled = true,
    this.forcedState,
    super.key,
  });

  /// Label above the field.
  final String label;

  /// Optional text controller.
  final TextEditingController? controller;

  /// Unit shown as suffix inside the field.
  final String? unit;

  /// Error text; shown as a red line under the field.
  final String? errorText;

  /// Whether the field accepts input.
  final bool enabled;

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
              style: text.bodyLarge,
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.enabled
                    ? c.surface
                    : c.onSurface.withValues(alpha: Tokens.tintAlpha),
                suffixText: widget.unit,
                suffixStyle: text.bodyMedium,
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
