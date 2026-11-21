import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'error_card_body.dart';
import 'focus_ring.dart';
import 'skeleton_bars.dart';
import 'visual_state.dart';

/// Paper-look card. Light: 1 dp border plus soft shadow (larger on hover).
/// Dark: 1 dp border and no shadow.
class AppCard extends StatefulWidget {
  /// Creates a card around [child]. A non-null [onTap] makes it interactive.
  const AppCard({
    required this.child,
    this.onTap,
    this.state = VisualState.normal,
    this.semanticLabel,
    this.padding = const EdgeInsets.all(Tokens.space16),
    super.key,
  });

  /// Skeleton placeholder card.
  const AppCard.loading({super.key})
    : child = const SkeletonBars(),
      onTap = null,
      state = VisualState.loading,
      semanticLabel = null,
      padding = const EdgeInsets.all(Tokens.space16);

  /// Error card with message and retry action.
  AppCard.error({
    required String message,
    required VoidCallback onRetry,
    super.key,
  }) : child = ErrorCardBody(message: message, onRetry: onRetry),
       onTap = null,
       state = VisualState.error,
       semanticLabel = null,
       padding = const EdgeInsets.all(Tokens.space16);

  /// Card content.
  final Widget child;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Forced visual state (hover, selected, disabled, error, focus ...).
  final VisualState state;

  /// Accessible label for interactive cards.
  final String? semanticLabel;

  /// Space between the card border and [child].
  final EdgeInsetsGeometry padding;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = widget.state;
    final hover = _hover || state == VisualState.hover;
    final selected = state == VisualState.selected;
    final error = state == VisualState.error;
    final borderColor = error
        ? c.error
        : selected
        ? c.accent
        : c.border;
    final shadowColor = c.shadow;
    final radius = BorderRadius.circular(Tokens.radiusCard);
    final disabled = state == VisualState.disabled;
    Widget card = FocusRing(
      focused: _focus || state == VisualState.focus,
      radius: Tokens.radiusCard,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceVariant,
          borderRadius: radius,
          border: Border.all(
            color: borderColor,
            width: selected || error
                ? Tokens.selectedBorderWidth
                : Tokens.borderWidth,
          ),
          boxShadow: shadowColor == null
              ? null
              : [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: Tokens.shadowBlur,
                    offset: Offset(
                      0,
                      hover ? Tokens.shadowOffsetHover : Tokens.shadowOffset,
                    ),
                  ),
                ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: disabled ? null : widget.onTap,
            onFocusChange: (v) => setState(() => _focus = v),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
    if (disabled) {
      card = Opacity(opacity: Tokens.disabledCardAlpha, child: card);
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        container: true,
        label: widget.semanticLabel,
        button: widget.onTap != null,
        enabled: !disabled,
        child: card,
      ),
    );
  }
}
