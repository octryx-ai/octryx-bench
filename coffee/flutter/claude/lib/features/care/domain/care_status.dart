/// Urgency of a care task.
enum CareStatus {
  /// Due now or overdue (0 days left or fewer).
  due,

  /// Due in one or two days.
  soon,

  /// More than two days left.
  ok,
}
