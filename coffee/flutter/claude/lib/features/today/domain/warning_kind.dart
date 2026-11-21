/// Kind of warning shown on the Today screen.
enum WarningKind {
  /// A gap without ready coffee is coming.
  gap,

  /// A bean has to be reordered.
  order,

  /// A care task is due.
  careDue,

  /// A water profile is outside the SCA range.
  water,
}
