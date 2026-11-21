import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_services.dart';
import '../../../core/l10n_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/onboarding_tokens.dart';
import '../../../core/theme/tokens.dart';
import 'onboarding_actions.dart';
import 'onboarding_bean_page.dart';
import 'onboarding_grinder_page.dart';
import 'onboarding_header.dart';
import 'onboarding_progress.dart';

/// Onboarding (OE-75, R12): four pages, full screen without bottom bar, rail or
/// sidebar, in a centred column of at most 480 dp. Überspringen on any page sets
/// the flag and leads to Heute; the system back gesture does not leave page 1.
class OnboardingScreen extends StatefulWidget {
  /// Creates the screen.
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _total = 4;

  /// Current page: 1 Willkommen, 2 Funktionen, 3 Mühle, 4 Bohne.
  int _page = 1;
  bool _saving = false;
  bool _saveFailed = false;
  String? _grinderName;
  String? _beanName;
  final _grinderKey = GlobalKey<OnboardingGrinderPageState>();
  final _beanKey = GlobalKey<OnboardingBeanPageState>();

  void _showPage(int page) => setState(() => _page = page);

  /// Writes the flag and, only after success, shows Heute. On failure the page
  /// stays and the error banner offers a retry of this same call.
  Future<void> _skip() async {
    setState(() {
      _saving = true;
    });
    try {
      await AppServicesScope.of(context).onboarding.markDone();
    } on Object {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveFailed = true;
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.today, (_) => false);
  }

  /// Weiter on page 3: saves the grinder when the form is valid, then page 4.
  Future<void> _saveGrinderAndContinue() async {
    final state = _grinderKey.currentState;
    if (state == null) return;
    if (await state.submit() && mounted) _showPage(4);
  }

  void _rememberGrinder(String name) => setState(() => _grinderName = name);

  void _rememberBean(String name) => setState(() => _beanName = name);

  /// Page 4: Weiter saves the bean once and stays on the page; after that
  /// Los geht's finishes. Without a saved bean the page never leaves by Weiter.
  Future<void> _beanOrFinish() async {
    if (_beanName != null) return _skip();
    await _beanKey.currentState?.submit();
  }

  /// Später: page 3 leads to page 4; page 4 finishes without a bean.
  VoidCallback? _laterAction() => switch (_page) {
    3 => () => _showPage(4),
    4 => _skip,
    _ => null,
  };

  /// What the primary button does on the current page.
  VoidCallback _nextAction() {
    return switch (_page) {
      1 => () => _showPage(2),
      2 => () => _showPage(3),
      3 => _saveGrinderAndContinue,
      _ => _beanOrFinish,
    };
  }

  Widget _pageBody(BuildContext context) {
    return switch (_page) {
      1 => _welcomeText(context),
      2 => _featuresText(context),
      3 => OnboardingGrinderPage(
        key: _grinderKey,
        createdName: _grinderName,
        onCreated: _rememberGrinder,
      ),
      _ => OnboardingBeanPage(
        key: _beanKey,
        createdName: _beanName,
        grinderName: _grinderName,
        onCreated: _rememberBean,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = AppColors.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: c.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: OnboardingTokens.maxWidth,
              ),
              child: Column(
                key: const Key('onboarding-column'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const OnboardingHeader(icon: Icons.local_cafe),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Tokens.space24,
                      Tokens.space24,
                      Tokens.space24,
                      0,
                    ),
                    child: OnboardingProgress(step: _page, total: _total),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(Tokens.space24),
                      child: _pageBody(context),
                    ),
                  ),
                  OnboardingActions(
                    saving: _saving,
                    saveFailed: _saveFailed,
                    onSkip: _skip,
                    onNext: _nextAction(),
                    onBack: _page > 1 ? () => _showPage(_page - 1) : null,
                    onLater: _laterAction(),
                    nextLabel: _page == 4 && _beanName != null
                        ? l.onboardingLetsGo
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Welcome title and text; each is its own semantics node.
  Widget _welcomeText(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Semantics(
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            container: true,
            label: l.onboardingWelcomeTitle,
            child: ExcludeSemantics(
              child: Text(l.onboardingWelcomeTitle, style: text.headlineMedium),
            ),
          ),
          const SizedBox(height: Tokens.space12),
          Semantics(
            label: l.onboardingWelcomeText,
            container: true,
            child: ExcludeSemantics(
              child: Text(l.onboardingWelcomeText, style: text.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }

  /// Page 2: the three functions of the app, each its own semantics node.
  Widget _featuresText(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final c = AppColors.of(context);
    final items = [
      l.onboardingFeatureLog,
      l.onboardingFeatureTrack,
      l.onboardingFeatureTips,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          label: l.onboardingFeaturesTitle,
          child: ExcludeSemantics(
            child: Text(l.onboardingFeaturesTitle, style: text.headlineMedium),
          ),
        ),
        const SizedBox(height: Tokens.space16),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.space12),
            child: Semantics(
              label: item,
              child: ExcludeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: c.accent),
                    const SizedBox(width: Tokens.space12),
                    Expanded(child: Text(item, style: text.bodyLarge)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
