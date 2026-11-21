import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../domain/brew.dart';
import 'brew_format.dart';
import 'brew_image.dart';

/// Header band of the brew detail: large bean gradient with a cup, method and
/// bean name.
class BrewHeader extends StatelessWidget {
  /// Creates the header for [brew] of the bean called [beanName].
  const BrewHeader({required this.brew, required this.beanName, super.key});

  /// Brew shown.
  final Brew brew;

  /// Name of the bean used.
  final String beanName;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrewImage(
          beanName: beanName,
          width: double.infinity,
          height: Tokens.detailHeaderHeight,
          iconSize: Tokens.iconSize64,
          radius: Tokens.radiusCard,
        ),
        const SizedBox(height: Tokens.space12),
        Text(
          BrewFormat.method(context.l10n, brew.method),
          style: text.headlineMedium,
        ),
        Text(beanName, style: text.bodyLarge),
      ],
    );
  }
}
