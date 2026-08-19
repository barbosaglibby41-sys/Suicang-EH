import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final values = [
      _InfoItem('语言', metadata.language ?? '未知', Icons.language_outlined),
      _InfoItem('页数', '${gallery.pageCount}', Icons.layers_outlined),
      _InfoItem(
        '发布',
        gallery.postedAt == null ? '未知' : RelativeTime.format(gallery.postedAt!),
        Icons.schedule_outlined,
        detail: gallery.postedAt == null
            ? null
            : gallery.postedAt!.toLocal().toIso8601String().replaceFirst('T', ' ').split('.').first,
      ),
      _InfoItem('大小', metadata.fileSize ?? '未知', Icons.storage_outlined),
      _InfoItem('收藏', metadata.favoriteCount?.toString() ?? '—', Icons.favorite_border),
      _InfoItem('评分', gallery.rating?.toStringAsFixed(2) ?? '—', Icons.star_outline),
    ];

    return Semantics(
      label: '作品信息',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              for (var row = 0; row < 2; row++) ...[
                if (row > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      for (var column = 0; column < 3; column++) ...[
                        if (column > 0)
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        Expanded(child: _InfoCell(item: values[row * 3 + column])),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: item.detail ?? item.value,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 13, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(item.icon, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value, this.icon, {this.detail});

  final String label;
  final String value;
  final IconData icon;
  final String? detail;
}
