import '../../../core/widgets/banner_severity.dart';

/// One result line of an export, import or delete action.
class TransferMessage {
  /// Creates a message.
  const TransferMessage(this.severity, this.text);

  /// Banner severity.
  final BannerSeverity severity;

  /// Localized text.
  final String text;
}
