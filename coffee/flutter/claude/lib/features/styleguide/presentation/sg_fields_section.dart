import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/app_field.dart';
import '../../../core/widgets/visual_state.dart';
import 'sg_section.dart';
import 'sg_state.dart';

/// Style-guide: fields in every state.
class SgFieldsSection extends StatelessWidget {
  /// Creates the section.
  const SgFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SgSection(
      title: l.sgFields,
      children: [
        SgState(
          keyName: 'field-default',
          label: l.stateDefault,
          child: AppField(label: l.fieldLabel, unit: l.fieldUnit),
        ),
        SgState(
          keyName: 'field-focus',
          label: l.stateFocus,
          child: AppField(
            label: l.fieldLabel,
            unit: l.fieldUnit,
            forcedState: VisualState.focus,
          ),
        ),
        SgState(
          keyName: 'field-error',
          label: l.stateError,
          child: AppField(
            label: l.fieldLabel,
            unit: l.fieldUnit,
            errorText: l.fieldErrorText,
          ),
        ),
        SgState(
          keyName: 'field-disabled',
          label: l.stateDisabled,
          child: AppField(
            label: l.fieldLabel,
            unit: l.fieldUnit,
            enabled: false,
          ),
        ),
      ],
    );
  }
}
