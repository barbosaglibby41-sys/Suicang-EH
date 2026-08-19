import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_metadata.dart';

class GalleryStatsStrip extends StatelessWidget {
  const GalleryStatsStrip({
    required this.gallery,
    required this.metadata,
    super.key,
  });

  final Gallery gallery;
  final GalleryMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Stat('语言', metadata.language ?? '未知', Icons.language_outlined),
      _Stat('页数', '${gallery.pageCount}P', Icons.layers_outlined),
      _Stat(
        '发布',
        gallery.postedAt == null
            ? '未知'
            : RelativeTime.chinaCardDate(gallery.postedAt!),
        Icons.schedule_outlined,
        detail: gallery.postedAt == null
            ? null
            : '${RelativeTime.chinaDateTime(gallery.postedAt!)} 中国时间',
      ),
      _Stat('大小', metadata.fileSize ?? '—', Icons.storage_outlined),
      _Stat('收藏', metadata.favoriteCount?.toString() ?? '—', Icons.favorite_border),
      _Stat('评分', gallery.rating?.toStringAsFixed(2) ?? '—', Icons.star_outline),
    ];

    return Semantics(
      label: '作品统计信息，可横向滑动查看更多',
      child: SizedBox(
        height: 74,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => _StatPill(item: items[index]),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.item});

  final _Stat item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: item.detail ?? item.value,
      child: Container(
        width: 108,
        padding: const EdgeInsets.fromLTRB(11, 9, 9, 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(item.icon, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(item.label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon, {this.detail});

  final String label;
  final String value;
  final IconData icon;
  final String? detail;
}
