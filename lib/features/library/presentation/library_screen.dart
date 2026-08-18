import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/presentation/widgets/gallery_cover_placeholder.dart';
import 'providers/library_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteGalleriesProvider);
    final history = ref.watch(historyGalleriesProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('书架'),
          bottom: const TabBar(
            tabs: [Tab(text: '收藏'), Tab(text: '历史')],
          ),
        ),
        body: TabBarView(
          children: [
            _GalleryCollection(data: favorites, emptyText: '还没有本地收藏。'),
            _GalleryCollection(data: history, emptyText: '最近打开的作品会显示在这里。'),
          ],
        ),
      ),
    );
  }
}

class _GalleryCollection extends StatelessWidget {
  const _GalleryCollection({required this.data, required this.emptyText});

  final AsyncValue<List<Gallery>> data;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('书架暂时无法读取。')),
      data: (items) => items.isEmpty
          ? Center(child: Text(emptyText))
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 5
                    : constraints.maxWidth >= 600
                        ? 4
                        : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.57,
                  ),
                  itemBuilder: (context, index) => _GalleryCard(gallery: items[index]),
                );
              },
            ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.gallery});

  final Gallery gallery;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(
        '/gallery/${gallery.key.source.storageValue}/${gallery.key.gid}',
        extra: gallery,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: 'library-cover-${gallery.key.stableId}',
              child: GalleryCoverPlaceholder(gallery: gallery),
            ),
          ),
          const SizedBox(height: 8),
          Text(gallery.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(
            gallery.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
