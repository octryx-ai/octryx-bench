import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// Scrollable page content, centred with a maximum width. The surrounding
/// scaffold fills the viewport, so short content leaves no gap.
class PageBody extends StatelessWidget {
  /// Creates the body.
  const PageBody({required this.children, super.key});

  /// Content widgets, laid out in a column.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Tokens.contentMaxWidth),
        child: ListView(
          padding: const EdgeInsets.all(Tokens.space16),
          children: children,
        ),
      ),
    );
  }
}
