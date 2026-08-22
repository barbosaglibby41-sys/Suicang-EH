import 'package:flutter/material.dart';

import '../../domain/entities/gallery_comment.dart';
import 'gallery_comment_card.dart';

class GalleryCommentCarousel extends StatelessWidget {
  const GalleryCommentCarousel({
    required this.comments,
    required this.isVoting,
    required this.onVote,
    required this.onWrite,
    required this.onViewAll,
    super.key,
  });

  final List<GalleryComment> comments;
  final bool isVoting;
  final Future<void> Function(GalleryComment comment, bool upvote) onVote;
  final VoidCallback onWrite;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final visible = comments.take(5).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('评论', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            Text('${comments.length}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const Spacer(),
            TextButton(onPressed: onViewAll, child: const Text('查看全部评论')),
            IconButton(
              tooltip: '发表评论',
              onPressed: onWrite,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.91),
            itemCount: visible.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GalleryCommentCard(
                comment: visible[index],
                isVoting: isVoting,
                onVote: (upvote) => onVote(visible[index], upvote),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GalleryCommentsSheet extends StatelessWidget {
  const GalleryCommentsSheet({
    required this.comments,
    required this.isVoting,
    required this.onVote,
    required this.onWrite,
    super.key,
  });

  final List<GalleryComment> comments;
  final bool isVoting;
  final Future<void> Function(GalleryComment comment, bool upvote) onVote;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.86,
        child: Column(
          children: [
            ListTile(
              title: Text('全部评论 · ${comments.length}'),
              trailing: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => GalleryCommentCard(
                  comment: comments[index],
                  isVoting: isVoting,
                  onVote: (upvote) => onVote(comments[index], upvote),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: FilledButton.icon(
                onPressed: onWrite,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('发表评论'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
