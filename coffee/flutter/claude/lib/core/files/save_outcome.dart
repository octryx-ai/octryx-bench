/// How a saved export reached the user.
enum SaveOutcome {
  /// The browser downloaded the file.
  downloaded,

  /// The system share sheet was opened with the file.
  shared,

  /// The text was copied to the clipboard (no share sheet available).
  copied,
}
