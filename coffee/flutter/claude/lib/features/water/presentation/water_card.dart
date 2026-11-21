import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_scope.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/water_profile.dart';
import 'water_format.dart';
import 'water_status_chip.dart';

/// List card of a water profile: drop visual, name, hardness in the selected
/// unit and the SCA status chip. Tap opens the detail.
class WaterCard extends StatelessWidget {
  /// Creates the card.
  const WaterCard({required this.profile, super.key});

  /// Profile shown.
  final WaterProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final data = AppScope.of(context);
    final inRange = data.checker.assess(profile).inScaRange;
    return SizedBox(
      height: Tokens.listCardHeight,
      child: AppCard(
        key: Key('water-${profile.id}'),
        semanticLabel: profile.name,
        onTap: () =>
            Navigator.of(context)
                .pushNamed(AppRoutes.waterDetail, arguments: profile.id),
        child: Row(
          children: [
            SizedBox(
              width: Tokens.listVisualSize,
              height: Tokens.listVisualSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: Tokens.tintAlpha),
                  borderRadius: BorderRadius.circular(Tokens.radiusField),
                ),
                child: Icon(Icons.water_drop, color: c.accent),
              ),
            ),
            const SizedBox(width: Tokens.space16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        WaterFormat.hardness(
                          l,
                          data.hardnessUnit,
                          profile.hardnessPpm,
                        ),
                        style: text.bodyMedium,
                      ),
                      const SizedBox(width: Tokens.space8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: WaterStatusChip(inRange: inRange),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
