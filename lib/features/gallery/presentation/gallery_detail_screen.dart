import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/image/image_request.dart';
import '../../../core/image/pipeline_image.dart';
import '../domain/entities/gallery.dart';
import 'notifiers/gallery_detail_notifier.dart';
import 'widgets/gallery_cover_placeholder.dart';

class GalleryDetailScreen extends ConsumerStatefulWidget {
  const GalleryDetailScreen({
    required this.gallery,
    super.key,
  });

  final Gallery gallery;

  @override
  ConsumerState<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends ConsumerState<GalleryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galleryDetailNotifierProvider(widget.gallery).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryDetailNotifierProvider(widget.gallery));
    final notifier =
        ref.read(galleryDetailNotifierProvider(widget.gallery).notifier);
    final gallery = state.gallery;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'gallery-cover-${gallery.key.stableId}',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 88, 48, 24),
                  child: AspectRatio(
                    aspectRatio: 0.72,
                    child: gallery.thumbnailUrl == null
                        ? GalleryCoverPlaceholder(gallery: gallery)
                        : PipelineImage(
                            url: gallery.thumbnailUrl!,
                            source: gallery.key.source,
                            variant: ImageVariant.cover,
                            targetPixels: 720,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(12),
                          ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: '更多操作',
                onPressed: () {},
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(gallery.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  [
                    if (gallery.uploader.isNotEmpty) gallery.uploader,
                    if (gallery.category.isNotEmpty) gallery.category,
                    if (gallery.pageCount > 0) '${gallery.pageCount} 页',
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: gallery.sourceUrl == null ? null : () {},
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('开始阅读'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.star_outline),
                        label: const Text('收藏'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('下载'),
                      ),
                    ),
                  ],
                ),
                if (state.isLoading) ...[
                  const SizedBox(height: 24),
                  const LinearProgressIndicator(),
                ],
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  _DetailError(
                    message: state.errorMessage!,
                    onRetry: notifier.load,
                  ),
                ],
                if (gallery.tags.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text('标签', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in gallery.tags)
                        Chip(label: Text(tag.translatedName ?? tag.rawName)),
                    ],
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
            IconButton(
              tooltip: '重试',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
