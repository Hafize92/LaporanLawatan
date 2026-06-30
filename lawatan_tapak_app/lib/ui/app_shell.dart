import 'package:flutter/material.dart';

import '../state/lawatan_app_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/map_screen.dart';
import 'screens/photo_screen.dart';
import 'screens/report_screen.dart';

class LawatanAppShell extends StatelessWidget {
  const LawatanAppShell({super.key, required this.state});

  final LawatanAppState state;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Projek',
    ),
    NavigationDestination(
      icon: Icon(Icons.photo_camera_outlined),
      selectedIcon: Icon(Icons.photo_camera),
      label: 'Gambar',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'Peta',
    ),
    NavigationDestination(
      icon: Icon(Icons.picture_as_pdf_outlined),
      selectedIcon: Icon(Icons.picture_as_pdf),
      label: 'Laporan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final screens = <Widget>[
          DashboardScreen(state: state),
          PhotoScreen(state: state),
          MapScreen(state: state),
          ReportScreen(state: state),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Lawatan Tapak'),
                centerTitle: false,
              ),
              body: isWide
                  ? Row(
                      children: <Widget>[
                        NavigationRail(
                          selectedIndex: state.selectedIndex,
                          onDestinationSelected: state.selectTab,
                          labelType: NavigationRailLabelType.all,
                          destinations: _destinations
                              .map(
                                (destination) => NavigationRailDestination(
                                  icon: destination.icon,
                                  selectedIcon: destination.selectedIcon,
                                  label: Text(destination.label),
                                ),
                              )
                              .toList(),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: screens[state.selectedIndex]),
                      ],
                    )
                  : screens[state.selectedIndex],
              bottomNavigationBar: isWide
                  ? null
                  : NavigationBar(
                      selectedIndex: state.selectedIndex,
                      onDestinationSelected: state.selectTab,
                      destinations: _destinations,
                    ),
            );
          },
        );
      },
    );
  }
}
