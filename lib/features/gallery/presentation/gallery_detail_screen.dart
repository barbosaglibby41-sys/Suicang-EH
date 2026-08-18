import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/image/image_request.dart';
import '../../../core/image/pipeline_image.dart';
import '../../../tags/presentation/providers/subscribed_tags_providers.dart';
import '../domain/entities/gallery.dart';
import 'notifiers/gallery_detail_notifier.dart';
import 'widgets/gallery_comment_card.dart';
import 'widgets/gallery_info_card.dart';
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
  late Future<bool> _favorite;

  @override
  void initState() {
    super.initState();
    _favorite = Future.value(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(galleryDetailNotifierProvider(widget.gallery).notifier);
      notifier.load();
      notifier.recordOpened();
      if (mounted) setState(() => _favorite = notifier.isFavorite());
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
                tooltip: '账户收藏',
                onPressed: () => context.push('/cloud-favorites'),
                icon: const Icon(Icons.cloud_outlined),
              ),
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
                const SizedBox(height: 20),
                GalleryInfoCard(gallery: gallery, metadata: state.metadata),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: gallery.sourceUrl == null
                        ? null
                        : () => context.push(
                              '/reader/${gallery.key.source.storageValue}/${gallery.key.gid}',
                              extra: gallery,
                            ),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('开始阅读'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<bool>(
                        future: _favorite,
                        builder: (context, snapshot) => OutlinedButton.icon(
                          onPressed: () async {
                            await notifier.toggleFavorite();
                            if (!mounted) return;
                            setState(() => _favorite = notifier.isFavorite());
                          },
                          icon: Icon(
                            snapshot.data == true
                                ? Icons.star
                                : Icons.star_outline,
                          ),
                          label: Text(snapshot.data == true ? '已收藏' : '收藏'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: '加入账户收藏夹 1',
                      onPressed: state.isLoading
                          ? null
                          : () => notifier.setCloudFavorite(category: 0, value: true),
                      icon: const Icon(Icons.cloud_upload_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: state.isLoading ? null : notifier.enqueueDownload,
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
                if (state.comments.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text('评论 · ${state.comments.length}', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (final comment in state.comments) ...[
                    GalleryCommentCard(comment: comment),
                    const SizedBox(height: 10),
                  ],
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
                        Consumer(
                          builder: (context, ref, _) {
                            final subscriptions = ref.watch(subscribedTagsProvider);
                            final isSubscribed = subscriptions.valueOrNull
                                    ?.contains(tag.rawName) ??
                                false;
                            return ActionChip(
                              avatar: Icon(
                                isSubscribed
                                    ? Icons.notifications_active_outlined
                                    : Icons.sell_outlined,
                                size: 16,
                              ),
                              label: Text(tag.translatedName ?? tag.rawName),
                              onPressed: () => ref
                                  .read(subscribedTagsRepositoryProvider)
                                  .toggle(tag.rawName),
                            );
                          },
                        ),
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
