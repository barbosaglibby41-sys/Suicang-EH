import 'package:flutter/material.dart';

import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_metadata.dart';

class GalleryInfoCard extends StatelessWidget {
  const GalleryInfoCard({
    required this.gallery,
    required this.metadata,
    super.key,
  });

  final Gallery gallery;
  final GalleryMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('语言', metadata.language ?? '未知', Icons.language_outlined),
      ('页数', '${gallery.pageCount}', Icons.layers_outlined),
      (
        '发布',
        gallery.postedAt == null
            ? '未知'
            : gallery.postedAt!.toIso8601String().split('T').first,
        Icons.calendar_today_outlined,
      ),
      ('大小', metadata.fileSize ?? '未知', Icons.storage_outlined),
      ('收藏', metadata.favoriteCount?.toString() ?? '—', Icons.favorite_border),
      ('评分', gallery.rating?.toStringAsFixed(2) ?? '—', Icons.star_outline),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final value in values)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(value.$3, size: 17),
                  const SizedBox(height: 5),
                  Text(value.$1, style: Theme.of(context).textTheme.labelSmall),
                  Text(value.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
