import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/visual_state.dart';
import 'sg_section.dart';
import 'sg_state.dart';

/// Style-guide: buttons in every state.
class SgButtonsSection extends StatelessWidget {
  /// Creates the section.
  const SgButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget tile(String key, String label, VisualState state) => SgState(
      keyName: 'button-$key',
      label: label,
      child: AppButton(
        label: l.save,
        forcedState: state,
        onPressed: state == VisualState.disabled ? null : () {},
      ),
    );
    return SgSection(
      title: l.sgButtons,
      children: [
        tile('default', l.stateDefault, VisualState.normal),
        tile('hover', l.stateHover, VisualState.hover),
        tile('pressed', l.statePressed, VisualState.pressed),
        tile('focus', l.stateFocus, VisualState.focus),
        tile('disabled', l.stateDisabled, VisualState.disabled),
        tile('loading', l.stateLoading, VisualState.loading),
      ],
    );
  }
}
