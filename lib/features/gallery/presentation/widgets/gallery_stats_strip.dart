import 'package:flutter/material.dart';

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
      _Stat('大小', metadata.fileSize ?? '—', Icons.storage_outlined),
      _Stat('收藏', metadata.favoriteCount?.toString() ?? '—',
          Icons.favorite_border),
      _Stat(
          '评分', gallery.rating?.toStringAsFixed(2) ?? '—', Icons.star_outline),
    ];

    return Semantics(
      label: '作品统计信息',
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          mainAxisExtent: 68,
        ),
        itemBuilder: (context, index) => _StatPill(item: items[index]),
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
        padding: const EdgeInsets.fromLTRB(8, 7, 7, 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(13),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
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
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
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
