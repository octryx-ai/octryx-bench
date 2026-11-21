import 'package:material_ui/material_ui.dart';

import 'app_data.dart';

/// Provides [AppData] to the widget tree and rebuilds dependents on change.
class AppScope extends InheritedNotifier<AppData> {
  /// Creates a scope exposing [data] to [child].
  const AppScope({super.key, required AppData data, required super.child})
    : super(notifier: data);

  /// The nearest [AppData]; listens for changes.
  static AppData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!.notifier!;
  }
}
