import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/banner_severity.dart';
import 'sg_section.dart';
import 'sg_state.dart';

/// Style-guide: info, warning and error banners.
class SgBannersSection extends StatelessWidget {
  /// Creates the section.
  const SgBannersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SgSection(
      title: l.sgBanners,
      children: [
        SgState(
          keyName: 'banner-info',
          label: l.bannerInfo,
          child: AppBanner(
            severity: BannerSeverity.info,
            message: l.bannerInfoText,
          ),
        ),
        SgState(
          keyName: 'banner-warning',
          label: l.bannerWarning,
          child: AppBanner(
            severity: BannerSeverity.warning,
            message: l.bannerWarningText,
            actionLabel: l.bannerAction,
            onAction: () {},
          ),
        ),
        SgState(
          keyName: 'banner-error',
          label: l.bannerError,
          child: AppBanner(
            severity: BannerSeverity.error,
            message: l.bannerErrorText,
            actionLabel: l.retry,
            onAction: () {},
          ),
        ),
      ],
    );
  }
}
