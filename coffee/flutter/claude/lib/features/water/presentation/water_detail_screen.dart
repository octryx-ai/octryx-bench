import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/banner_severity.dart';
import '../../../core/widgets/delete_action.dart';
import '../../../core/widgets/page_body.dart';
import '../domain/water_profile.dart';
import 'water_format.dart';
import 'water_parameter_bar.dart';
import 'water_status_chip.dart';

/// Detail of a water profile: hardness in the selected unit, status chip,
/// "check water first" hint, measured count and one bar per parameter.
class WaterDetailScreen extends StatelessWidget {
  /// Creates the detail of the profile with [profileId].
  const WaterDetailScreen({required this.profileId, super.key});

  /// Id of the profile shown.
  final String? profileId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final data = AppScope.of(context);
    final id = profileId;
    final WaterProfile? profile = id == null ? null : data.waterProfileById(id);
    if (profile == null || profile.isDeleted) {
      return Scaffold(appBar: AppBar(title: Text(l.waterDetail)));
    }
    final assessment = data.checker.assess(profile);
    final violation = assessment.firstViolation;
    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name),
        actions: [
          IconButton(
            key: const Key('action-edit'),
            tooltip: l.edit,
            icon: Semantics(label: l.edit, child: const Icon(Icons.edit)),
            constraints: const BoxConstraints(
              minWidth: Tokens.touchTarget,
              minHeight: Tokens.touchTarget,
            ),
            onPressed: () =>
                Navigator.of(context)
                    .pushNamed(AppRoutes.waterEdit, arguments: profile.id),
          ),
          DeleteAction(
            name: profile.name,
            onDelete: () {
              final navigator = Navigator.of(context);
              data.deleteWaterProfile(profile.id);
              navigator.pop();
            },
          ),
        ],
      ),
      body: PageBody(
        children: [
          if (violation != null) ...[
            AppBanner(
              severity: BannerSeverity.warning,
              message: l.waterCheckFirst(
                WaterFormat.inlineLabel(l, violation.parameter),
                WaterFormat.value(l, violation.parameter, violation.value!),
                WaterFormat.range(l, violation.parameter, violation.range),
              ),
            ),
            const SizedBox(height: Tokens.space16),
          ],
          AppCard(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.paramHardness, style: text.labelLarge),
                  Text(
                    WaterFormat.hardness(
                      l,
                      data.hardnessUnit,
                      profile.hardnessPpm,
                    ),
                    style: text.headlineMedium,
                  ),
                  const SizedBox(height: Tokens.space12),
                  Wrap(
                    spacing: Tokens.space12,
                    runSpacing: Tokens.space8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      WaterStatusChip(inRange: assessment.inScaRange),
                      Text(
                        l.measuredOf(
                          assessment.measuredCount,
                          assessment.results.length,
                        ),
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.space16),
          AppCard(
            child: Column(
              children: [
                for (final r in assessment.results)
                  WaterParameterBar(result: r),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
