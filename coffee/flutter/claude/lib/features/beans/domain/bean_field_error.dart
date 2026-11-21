/// Validation errors of bean and pack forms.
enum BeanFieldError {
  /// Name is empty.
  nameRequired,

  /// Name exceeds 60 characters.
  nameTooLong,

  /// Pack size missing.
  sizeRequired,

  /// Pack size outside 50 to 5000 g.
  sizeOutOfRange,

  /// Lead time missing.
  leadTimeRequired,

  /// Lead time outside 0 to 60 days.
  leadTimeOutOfRange,

  /// Minimum stock outside 0 to 5000 g.
  minStockOutOfRange,

  /// Roast date missing.
  roastDateRequired,

  /// Roast date lies in the future.
  roastDateInFuture,
}
