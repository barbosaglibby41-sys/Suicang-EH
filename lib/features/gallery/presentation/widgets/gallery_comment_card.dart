import 'package:flutter/material.dart';

import '../../domain/entities/gallery_comment.dart';

class GalleryCommentCard extends StatelessWidget {
  const GalleryCommentCard({
    required this.comment,
    this.onVote,
    this.isVoting = false,
    super.key,
  });

  final GalleryComment comment;
  final Future<void> Function(bool upvote)? onVote;
  final bool isVoting;

  @override
  Widget build(BuildContext context) {
    final score = comment.score;
    final scoreColor = score == null
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : score > 0
            ? Colors.green
            : score < 0
                ? Colors.red
                : Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      color: comment.isUploader
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(comment.author,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                if (comment.isUploader)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Chip(label: Text('上传者')),
                  ),
                if (score != null)
                  Text(score > 0 ? '+$score' : '$score',
                      style: TextStyle(color: scoreColor)),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(comment.content),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    [
                      comment.postedAt,
                      if (comment.votes?.isNotEmpty ?? false) comment.votes!
                    ].join(' · '),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                if (onVote != null)
                  if (isVoting)
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else ...[
                    IconButton(
                      tooltip: '顶',
                      onPressed: () => onVote!(true),
                      icon: const Icon(Icons.thumb_up_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: '踩',
                      onPressed: () => onVote!(false),
                      icon: const Icon(Icons.thumb_down_outlined, size: 18),
                    ),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
