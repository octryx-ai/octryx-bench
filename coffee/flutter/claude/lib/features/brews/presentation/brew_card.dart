import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/brew.dart';
import 'brew_format.dart';
import 'brew_image.dart';

/// List card of a brew: bean gradient with cup icon, method, bean name, shot
/// time and rating. Tap opens the detail.
class BrewCard extends StatelessWidget {
  /// Creates the card for [brew] of the bean called [beanName].
  const BrewCard({required this.brew, required this.beanName, super.key});

  /// Brew shown.
  final Brew brew;

  /// Name of the bean the brew used.
  final String beanName;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final method = BrewFormat.method(l, brew.method);
    final time = BrewFormat.time(l, brew);
    final rating = brew.rating;
    return SizedBox(
      height: Tokens.listCardHeight,
      child: AppCard(
        key: Key('brew-${brew.id}'),
        semanticLabel: [
          method,
          beanName,
          time,
          if (rating != null) l.ratingStars(rating),
        ].join(', '),
        padding: const EdgeInsets.symmetric(
          horizontal: Tokens.space12,
          vertical: Tokens.space8,
        ),
        onTap: () =>
            Navigator.of(context)
                .pushNamed(AppRoutes.brewDetail, arguments: brew.id),
        child: Row(
          children: [
            BrewImage(beanName: beanName),
            const SizedBox(width: Tokens.space12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    beanName,
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          time,
                          key: Key('brew-time-${brew.id}'),
                          style: text.titleSmall,
                        ),
                      ),
                      if (rating != null)
                        Text(
                          BrewFormat.rating(rating),
                          key: Key('brew-rating-${brew.id}'),
                          style: text.titleSmall,
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
