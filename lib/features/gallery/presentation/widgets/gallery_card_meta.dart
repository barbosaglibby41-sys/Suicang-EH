import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';
import '../../domain/entities/gallery.dart';

class GalleryCardMeta extends StatelessWidget {
  const GalleryCardMeta({required this.gallery, super.key});

  final Gallery gallery;

  @override
  Widget build(BuildContext context) {
    final values = <String>[
      if (gallery.category.isNotEmpty) gallery.category,
      if (gallery.pageCount > 0) '${gallery.pageCount} 页',
      if (gallery.postedAt != null) RelativeTime.chinaCardDate(gallery.postedAt!),
    ];
    if (values.isEmpty) return const SizedBox.shrink();
    return Text(
      values.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
