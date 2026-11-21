import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/page_body.dart';
import 'sg_banners_section.dart';
import 'sg_buttons_section.dart';
import 'sg_cards_section.dart';
import 'sg_chips_section.dart';
import 'sg_colors_section.dart';
import 'sg_fields_section.dart';
import 'sg_other_section.dart';

/// Style-guide page at `/styleguide`: every component in every state.
class StyleGuideScreen extends StatelessWidget {
  /// Creates the screen.
  const StyleGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.styleGuide)),
      body: PageBody(
        children: [
          Text(l.sgIntro, style: Theme.of(context).textTheme.bodyMedium),
          const SgColorsSection(),
          const SgButtonsSection(),
          const SgCardsSection(),
          const SgFieldsSection(),
          const SgChipsSection(),
          const SgBannersSection(),
          const SgOtherSection(),
        ],
      ),
    );
  }
}
