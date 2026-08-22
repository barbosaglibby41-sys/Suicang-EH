import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';
import '../../domain/entities/gallery.dart';

class GalleryCardMeta extends StatelessWidget {
  const GalleryCardMeta({required this.gallery, super.key});

  final Gallery gallery;

  @override
  Widget build(BuildContext context) {
    final primary = <String>[
      if (gallery.category.isNotEmpty) gallery.category,
      if (gallery.pageCount > 0) '${gallery.pageCount} 页',
    ];
    final published = gallery.postedAt == null
        ? null
        : RelativeTime.chinaDateTime(gallery.postedAt!);
    if (primary.isEmpty && published == null) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (primary.isNotEmpty)
          Text(
            primary.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        if (published != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              RelativeTime.chinaCardDate(gallery.postedAt!),
              maxLines: 1,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: style,
            ),
          ),
      ],
    );
  }
}
