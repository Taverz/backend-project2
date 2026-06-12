import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _tabs = [
    (
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Главная',
      path: Routes.home,
    ),
    (
      icon: Icons.search,
      activeIcon: Icons.search,
      label: 'Поиск',
      path: Routes.search,
    ),
    (
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Уведомления',
      path: Routes.notifications,
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Профиль',
      path: Routes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
