/// Visual state a component can be forced into (style guide, tests).
enum VisualState {
  /// Resting state.
  normal,

  /// Pointer hovers the component.
  hover,

  /// Component is pressed.
  pressed,

  /// Keyboard focus ring is shown.
  focus,

  /// Component is disabled.
  disabled,

  /// Component is loading.
  loading,

  /// Component is selected.
  selected,

  /// Component shows an error.
  error,
}
