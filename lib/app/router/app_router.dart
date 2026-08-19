import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/gallery/domain/entities/gallery.dart';
import '../../features/gallery/domain/entities/gallery_key.dart';
import '../../features/gallery/presentation/gallery_detail_screen.dart';
import '../../features/reader/presentation/reader_screen.dart';
import '../../features/gallery/presentation/providers/gallery_providers.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/downloads/presentation/downloads_screen.dart';
import '../../features/authentication/presentation/account_screen.dart';
import '../../features/favorites/presentation/cloud_favorites_screen.dart';
import '../../features/offline/presentation/offline_library_screen.dart';
import '../../features/rankings/presentation/rankings_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      GoRoute(
        path: '/rankings',
        builder: (context, state) => const RankingsScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/cloud-favorites',
        builder: (context, state) => const CloudFavoritesScreen(),
      ),
      GoRoute(
        path: '/reader/:source/:gid',
        builder: (context, state) {
          final gallery = state.extra as Gallery?;
          if (gallery == null) {
            return const _InvalidGalleryRoute(
              message: 'Reader 需要从作品详情打开。',
            );
          }
          final startPage = int.tryParse(state.uri.queryParameters['page'] ?? '');
          return ReaderScreen(
            gallery: gallery,
            initialIndex: startPage == null ? 0 : startPage - 1,
          );
        },
      ),
      GoRoute(
        path: '/gallery/:source/:gid',
        builder: (context, state) {
          final source = SiteSource.fromStorageValue(
            state.pathParameters['source'] ?? '',
          );
          final gid = int.tryParse(state.pathParameters['gid'] ?? '');
          if (gid == null || gid <= 0) {
            return const _InvalidGalleryRoute();
          }
          final gallery = state.extra as Gallery?;
          if (gallery != null &&
              gallery.key.source == source &&
              gallery.key.gid == gid) {
            return GalleryDetailScreen(gallery: gallery);
          }
          return _RestoredGalleryDetail(
            galleryKey: GalleryKey(source: source, gid: gid),
          );
        },
      ),
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
            path: '/offline',
            builder: (context, state) => const OfflineLibraryScreen(),
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
                          selectedIcon: Icon(route.icon),
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
            onDestinationSelected: (index) =>
                context.go(destinations[index].path),
            destinations: [
              for (final route in destinations)
                NavigationDestination(
                  icon: Icon(route.icon),
                  selectedIcon: Icon(route.icon),
                  label: route.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RestoredGalleryDetail extends ConsumerWidget {
  const _RestoredGalleryDetail({required this.galleryKey});

  final GalleryKey galleryKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Gallery?>(
      future: ref.read(galleryRepositoryProvider).findByKey(galleryKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final gallery = snapshot.data;
        if (gallery == null) {
          return const _InvalidGalleryRoute(
            message: '该作品不在本机缓存中。请从发现或搜索结果中重新打开。',
          );
        }
        return GalleryDetailScreen(gallery: gallery);
      },
    );
  }
}

class _InvalidGalleryRoute extends StatelessWidget {
  const _InvalidGalleryRoute({
    this.message = '画廊地址无效。',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
