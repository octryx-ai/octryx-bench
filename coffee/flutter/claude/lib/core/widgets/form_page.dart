import 'package:material_ui/material_ui.dart';

import '../l10n_context.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'app_button.dart';
import 'page_body.dart';

/// Form scaffold: back button, title, scrolling single-column [children] and
/// a fixed bottom bar with the one filled primary Save button and Cancel.
class FormPage extends StatelessWidget {
  /// Creates the page.
  const FormPage({
    required this.title,
    required this.children,
    required this.onSave,
    this.actions = const [],
    this.saveLabel,
    super.key,
  });

  /// Page title.
  final String title;

  /// Form fields.
  final List<Widget> children;

  /// Save callback; null disables the primary button.
  final VoidCallback? onSave;

  /// Label of the primary button; defaults to "Save".
  final String? saveLabel;

  /// Top-bar actions.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Column(
        children: [
          Expanded(child: PageBody(children: children)),
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: SafeArea(
              top: false,
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Tokens.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Tokens.space16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          key: const Key('form-cancel'),
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(
                              Tokens.touchTarget,
                              Tokens.touchTarget,
                            ),
                            foregroundColor: c.accent,
                          ),
                          child: Text(l.cancel),
                        ),
                        const SizedBox(width: Tokens.space12),
                        AppButton(
                          key: const Key('form-save'),
                          label: saveLabel ?? l.save,
                          onPressed: onSave,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
