import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/presentation/widgets/gallery_cover.dart';
import '../../library/domain/entities/library_filter.dart';
import 'providers/cloud_favorites_providers.dart';

class CloudFavoritesScreen extends ConsumerStatefulWidget {
  const CloudFavoritesScreen({
    this.embedded = false,
    this.sort = LibrarySort.favoriteTime,
    this.date,
    super.key,
  });

  final bool embedded;
  final LibrarySort sort;
  final DateTime? date;

  @override
  ConsumerState<CloudFavoritesScreen> createState() =>
      _CloudFavoritesScreenState();
}

class _CloudFavoritesScreenState extends ConsumerState<CloudFavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cloudFavoritesNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudFavoritesNotifierProvider);
    final notifier = ref.read(cloudFavoritesNotifierProvider.notifier);
    final categories = state.categories.isEmpty
        ? ref.read(cloudFavoritesRepositoryProvider).defaultCategories()
        : state.categories;
    final galleries = _filterGalleries(state.galleries);
    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: DropdownButtonFormField<int>(
            initialValue: state.category,
            items: [
              for (final category in categories)
                DropdownMenuItem(
                    value: category.id, child: Text(category.name)),
            ],
            onChanged: state.isLoading
                ? null
                : (value) {
                    if (value != null) notifier.load(category: value);
                  },
            decoration: const InputDecoration(labelText: '收藏夹'),
          ),
        ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              state.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: state.isLoading && state.galleries.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : galleries.isEmpty
                  ? const Center(child: Text('这个收藏夹没有符合日期条件的作品。'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount:
                          galleries.length + (state.nextUrl == null ? 0 : 1),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 180,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.57,
                      ),
                      itemBuilder: (context, index) {
                        if (index == galleries.length) {
                          return Card(
                            child: InkWell(
                              onTap: state.isLoading
                                  ? null
                                  : () => notifier.load(more: true),
                              child: Center(
                                child: state.isLoading
                                    ? const CircularProgressIndicator()
                                    : const Icon(Icons.add),
                              ),
                            ),
                          );
                        }
                        return _CloudGalleryCard(gallery: galleries[index]);
                      },
                    ),
        ),
      ],
    );
    if (widget.embedded) return content;
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户收藏'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: state.isLoading
                ? null
                : () => notifier.load(category: state.category),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content,
    );
  }

  List<Gallery> _filterGalleries(List<Gallery> source) {
    final filtered = [
      for (final gallery in source)
        if (widget.date == null || _sameDay(gallery.postedAt, widget.date!))
          gallery,
    ];
    filtered.sort((left, right) {
      if (widget.sort == LibrarySort.publishedTime) {
        return (right.postedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(left.postedAt ?? DateTime.fromMillisecondsSinceEpoch(0));
      }
      return 0;
    });
    return filtered;
  }

  bool _sameDay(DateTime? value, DateTime date) =>
      value != null &&
      value.year == date.year &&
      value.month == date.month &&
      value.day == date.day;
}

class _CloudGalleryCard extends StatelessWidget {
  const _CloudGalleryCard({required this.gallery});

  final Gallery gallery;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: gallery.title,
        hint: '打开作品详情',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(
            '/gallery/${gallery.key.source.storageValue}/${gallery.key.gid}',
            extra: gallery,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: GalleryCover(gallery: gallery)),
              const SizedBox(height: 8),
              Text(gallery.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}
