import 'package:material_ui/material_ui.dart';

import '../../../app/app_routes.dart';
import '../../../app/app_section.dart';
import '../../../app/app_shell.dart';
import '../../../core/l10n_context.dart';
import '../../../core/widgets/add_action.dart';
import 'grinder_list.dart';
import 'machine_list.dart';

/// Ausrüstung with the tabs Mühlen and Maschinen.
class EquipmentScreen extends StatelessWidget {
  /// Creates the screen.
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: AppShell(
        section: AppSection.equipment,
        title: l.equipment,
        actions: [
          Builder(
            builder: (context) {
              final tab = DefaultTabController.of(context);
              return ListenableBuilder(
                listenable: tab,
                builder: (context, _) => tab.index == 0
                    ? AddAction(
                        route: AppRoutes.grinderNew,
                        label: l.grinderAdd,
                      )
                    : AddAction(
                        route: AppRoutes.machineNew,
                        label: l.machineAdd,
                      ),
              );
            },
          ),
        ],
        bottom: TabBar(
          tabs: [
            Tab(key: const Key('tab-grinders'), text: l.grinders),
            Tab(key: const Key('tab-machines'), text: l.machines),
          ],
        ),
        body: TabBarView(children: const [GrinderList(), MachineList()]),
      ),
    );
  }
}
