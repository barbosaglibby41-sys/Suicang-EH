import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../gallery/domain/entities/gallery.dart';
import '../../gallery/presentation/widgets/gallery_cover.dart';
import 'providers/cloud_favorites_providers.dart';

class CloudFavoritesScreen extends ConsumerStatefulWidget {
  const CloudFavoritesScreen({super.key});

  @override
  ConsumerState<CloudFavoritesScreen> createState() => _CloudFavoritesScreenState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户收藏'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: state.isLoading ? null : () => notifier.load(category: state.category),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: DropdownButtonFormField<int>(
              value: state.category,
              items: [
                for (final category in categories)
                  DropdownMenuItem(value: category.id, child: Text(category.name)),
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
                : state.galleries.isEmpty
                    ? const Center(child: Text('这个收藏夹还是空的。'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.galleries.length + (state.nextUrl == null ? 0 : 1),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.57,
                        ),
                        itemBuilder: (context, index) {
                          if (index == state.galleries.length) {
                            return Card(
                              child: InkWell(
                                onTap: state.isLoading ? null : () => notifier.load(more: true),
                                child: Center(
                                  child: state.isLoading
                                      ? const CircularProgressIndicator()
                                      : const Icon(Icons.add),
                                ),
                              ),
                            );
                          }
                          return _CloudGalleryCard(gallery: state.galleries[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _CloudGalleryCard extends StatelessWidget {
  const _CloudGalleryCard({required this.gallery});

  final Gallery gallery;

  @override
  Widget build(BuildContext context) => InkWell(
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
      );
}
