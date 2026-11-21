import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/tokens.dart';
import '../domain/bean.dart';
import 'bean_format.dart';
import 'bean_image.dart';

/// Header band of the bean detail: large gradient image, name, roaster and
/// the kind and roast level.
class BeanHeader extends StatelessWidget {
  /// Creates the header.
  const BeanHeader({required this.bean, super.key});

  /// Bean shown.
  final Bean bean;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BeanImage(
          name: bean.name,
          roastLevel: bean.roastLevel,
          width: double.infinity,
          height: Tokens.detailHeaderHeight,
          iconSize: Tokens.iconSize64,
          radius: Tokens.radiusCard,
          dotInset: Tokens.space12,
        ),
        const SizedBox(height: Tokens.space12),
        Text(bean.name, style: text.headlineMedium),
        if (bean.roaster.isNotEmpty) Text(bean.roaster, style: text.bodyLarge),
        Text(
          l.kindAndRoast(
            BeanFormat.kind(l, bean.kind),
            BeanFormat.roast(l, bean.roastLevel),
          ),
          style: text.bodyMedium,
        ),
      ],
    );
  }
}
