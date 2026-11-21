import 'package:material_ui/material_ui.dart';

import '../../../core/theme/tokens.dart';

/// Style-guide section: heading followed by wrapped state tiles.
class SgSection extends StatelessWidget {
  /// Creates a section.
  const SgSection({required this.title, required this.children, super.key});

  /// Section heading.
  final String title;

  /// State tiles.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Tokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: Tokens.space12),
          Wrap(
            spacing: Tokens.space16,
            runSpacing: Tokens.space16,
            children: children,
          ),
        ],
      ),
    );
  }
}
