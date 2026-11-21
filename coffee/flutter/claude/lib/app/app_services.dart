import 'package:material_ui/material_ui.dart';

import '../core/files/file_transfer.dart';
import '../core/files/file_transfer_platform.dart';
import '../core/rules/bundle_rule_source.dart';
import '../features/settings/data/rule_sources_loader.dart';

/// Platform services the screens use besides the data: file transfer for
/// export and import, and the loader of the rule sources list. Tests inject
/// fakes.
class AppServices {
  /// Creates the services; defaults are the platform transfer and the asset
  /// bundle.
  AppServices({FileTransfer? transfer, RuleSourcesLoader? sources})
    : transfer = transfer ?? const PlatformFileTransfer(),
      sources = sources ?? RuleSourcesLoader(BundleRuleSource());

  /// Export and import of files.
  final FileTransfer transfer;

  /// Loader of all rule entries with their sources.
  final RuleSourcesLoader sources;
}

/// Provides [AppServices] to the widget tree.
class AppServicesScope extends InheritedWidget {
  /// Creates a scope exposing [services] to [child].
  const AppServicesScope({
    required this.services,
    required super.child,
    super.key,
  });

  /// The services.
  final AppServices services;

  /// The nearest services.
  static AppServices of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppServicesScope>();
    assert(scope != null, 'No AppServicesScope found in context');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) =>
      services != oldWidget.services;
}
