import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/image/image_request.dart';
import '../../../core/image/pipeline_image.dart';
import 'widgets/translated_tag_groups.dart';
import '../../follows/domain/entities/followed_creator.dart';
import '../../follows/presentation/followed_creators_screen.dart';
import '../domain/entities/gallery.dart';
import 'notifiers/gallery_detail_notifier.dart';
import 'widgets/gallery_comment_card.dart';
import 'widgets/comment_editor_sheet.dart';
import 'widgets/cloud_favorite_sheet.dart';
import 'widgets/gallery_stats_strip.dart';
import 'widgets/gallery_action_bar.dart';
import 'widgets/gallery_cover_placeholder.dart';
import 'widgets/preview_strip.dart';

class GalleryDetailScreen extends ConsumerStatefulWidget {
  const GalleryDetailScreen({
    required this.gallery,
    super.key,
  });

  final Gallery gallery;

  @override
  ConsumerState<GalleryDetailScreen> createState() =>
      _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends ConsumerState<GalleryDetailScreen> {
  late Future<bool> _favorite;

  @override
  void initState() {
    super.initState();
    _favorite = Future.value(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(galleryDetailNotifierProvider(widget.gallery).notifier);
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
            expandedHeight: 330,
            backgroundColor: Theme.of(context)
                .scaffoldBackgroundColor
                .withValues(alpha: 0.88),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'gallery-cover-${gallery.key.stableId}',
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 86, 0, 22),
                    child: SizedBox(
                      width: 160,
                      child: AspectRatio(
                        aspectRatio: 0.70,
                        child: gallery.thumbnailUrl == null
                            ? GalleryCoverPlaceholder(gallery: gallery)
                            : PipelineImage(
                                url: gallery.thumbnailUrl!,
                                source: gallery.key.source,
                                variant: ImageVariant.cover,
                                targetPixels: 720,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(18),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: '关注',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FollowedCreatorsScreen(),
                  ),
                ),
                icon: const Icon(Icons.notifications_outlined),
              ),
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
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  gallery.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(height: 1.15),
                ),
                const SizedBox(height: 7),
                Text(
                  [
                    if (gallery.uploader.isNotEmpty) gallery.uploader,
                    if (gallery.category.isNotEmpty) gallery.category,
                    if (gallery.pageCount > 0) '${gallery.pageCount} 页',
                  ].join(' · '),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                GalleryStatsStrip(gallery: gallery, metadata: state.metadata),
                const SizedBox(height: 18),
                FutureBuilder<bool>(
                  future: _favorite,
                  builder: (context, favoriteSnapshot) => GalleryActionBar(
                    isLoading: state.isLoading,
                    isFavorite: favoriteSnapshot.data == true,
                    onRead: gallery.sourceUrl == null
                        ? () {}
                        : () => context.push(
                              '/reader/${gallery.key.source.storageValue}/${gallery.key.gid}',
                              extra: gallery,
                            ),
                    onFavorite: () async {
                      await notifier.toggleFavorite();
                      if (mounted)
                        setState(() => _favorite = notifier.isFavorite());
                    },
                    onDownload: notifier.enqueueDownload,
                    onCloudFavorite: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => CloudFavoriteSheet(gallery: gallery),
                    ),
                    onFollow: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (sheetContext) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.brush_outlined),
                              title: const Text('关注作者'),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                notifier.followArtistOrUploader(
                                    FollowedCreatorKind.artist);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('关注发布者'),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                notifier.followArtistOrUploader(
                                    FollowedCreatorKind.uploader);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                if (state.previews.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text('内容预览', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  PreviewStrip(
                    previews: state.previews,
                    source: gallery.key.source,
                    onSelectPage: (preview) => context.push(
                      '/reader/${gallery.key.source.storageValue}/${gallery.key.gid}?page=${preview.page}',
                      extra: gallery,
                    ),
                  ),
                ],
                if (state.comments.isNotEmpty || gallery.sourceUrl != null) ...[
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Text('评论 · ${state.comments.length}',
                            style: theme.textTheme.titleLarge),
                      ),
                      TextButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => CommentEditorSheet(
                                    onSubmit: notifier.postComment,
                                  ),
                                ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('发表评论'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final comment in state.comments) ...[
                    GalleryCommentCard(
                      comment: comment,
                      isVoting: state.isLoading,
                      onVote: (upvote) => notifier.voteComment(
                        commentId: comment.id,
                        upvote: upvote,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
                if (gallery.tags.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text('标签', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TranslatedTagGroups(
                    tags: gallery.tags,
                    onSearch: (tag) => context.push(
                      '/home?query=${Uri.encodeComponent(tag.rawName)}',
                    ),
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
