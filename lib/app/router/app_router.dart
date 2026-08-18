import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/downloads/presentation/downloads_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppScaffold(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoute.library.path,
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: AppRoute.downloads.path,
            builder: (context, state) => const DownloadsScreen(),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

enum AppRoute {
  home('/home', '发现', Icons.auto_awesome_outlined),
  library('/library', '书架', Icons.local_library_outlined),
  downloads('/downloads', '下载', Icons.download_outlined),
  settings('/settings', '设置', Icons.tune_outlined);

  const AppRoute(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.currentPath,
    required this.child,
    super.key,
  });

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = AppRoute.values.indexWhere(
      (route) => route.path == currentPath,
    );
    final safeIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        final destinations = AppRoute.values;
        final body = SafeArea(top: false, child: child);

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: safeIndex,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (index) =>
                        context.go(destinations[index].path),
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Icon(Icons.menu_book_rounded),
                    ),
                    destinations: [
                      for (final route in destinations)
                        NavigationRailDestination(
                          icon: Icon(route.icon),
                          selectedIcon: Icon(route.icon, fill: 1),
                          label: Text(route.label),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: safeIndex,
            onDestinationSelected: (index) => context.go(destinations[index].path),
            destinations: [
              for (final route in destinations)
                NavigationDestination(
                  icon: Icon(route.icon),
                  selectedIcon: Icon(route.icon, fill: 1),
                  label: route.label,
                ),
            ],
          ),
        );
      },
    );
  }
}
