import 'package:material_ui/material_ui.dart';

import '../l10n_context.dart';
import '../theme/tokens.dart';
import 'focus_ring.dart';
import 'visual_state.dart';

/// Filled primary button with default, hover, pressed, disabled and loading
/// states. A null [onPressed] disables it.
class AppButton extends StatefulWidget {
  /// Creates a button.
  const AppButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.forcedState,
    super.key,
  });

  /// Button text.
  final String label;

  /// Tap callback; null means disabled.
  final VoidCallback? onPressed;

  /// Shows a spinner instead of the text.
  final bool loading;

  /// Renders a fixed state regardless of interaction.
  final VisualState? forcedState;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hover = false;
  bool _pressed = false;
  bool _focus = false;

  VisualState get _state {
    final forced = widget.forcedState;
    if (forced != null) return forced;
    if (widget.loading) return VisualState.loading;
    if (widget.onPressed == null) return VisualState.disabled;
    if (_pressed) return VisualState.pressed;
    if (_hover) return VisualState.hover;
    return VisualState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final disabled = state == VisualState.disabled;
    final base = switch (state) {
      VisualState.hover => Tokens.primaryHover,
      VisualState.pressed => Tokens.primaryPressed,
      _ => Tokens.primary,
    };
    final fill = disabled ? base.withValues(alpha: Tokens.disabledAlpha) : base;
    final enabled = !disabled && state != VisualState.loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? widget.onPressed : null,
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: FocusRing(
          focused: _focus || state == VisualState.focus,
          radius: Tokens.radiusField,
          child: Material(
            color: fill,
            borderRadius: BorderRadius.circular(Tokens.radiusField),
            child: InkWell(
              borderRadius: BorderRadius.circular(Tokens.radiusField),
              onTap: enabled ? widget.onPressed : null,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              onFocusChange: (v) => setState(() => _focus = v),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Tokens.touchTarget,
                  minWidth: Tokens.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tokens.space24,
                    vertical: Tokens.space12,
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: state == VisualState.loading
                        ? _spinner(context)
                        : _text(context, disabled),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _spinner(BuildContext context) => Semantics(
    label: context.l10n.loading,
    child: const SizedBox(
      width: Tokens.spinnerSize,
      height: Tokens.spinnerSize,
      child: CircularProgressIndicator(
        strokeWidth: Tokens.spinnerStroke,
        color: Tokens.onPrimary,
      ),
    ),
  );

  Widget _text(BuildContext context, bool disabled) => Text(
    widget.label,
    style: Theme.of(context).textTheme.labelLarge!.copyWith(
      color: disabled
          ? Tokens.onPrimary.withValues(alpha: Tokens.disabledAlpha)
          : Tokens.onPrimary,
    ),
  );
}
