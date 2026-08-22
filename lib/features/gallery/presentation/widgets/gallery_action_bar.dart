import 'package:flutter/material.dart';

class GalleryActionBar extends StatelessWidget {
  const GalleryActionBar({
    required this.onRead,
    required this.onFavorite,
    required this.onDownload,
    required this.onCloudFavorite,
    required this.onFollow,
    required this.onRate,
    required this.isFavorite,
    required this.isLoading,
    super.key,
  });

  final VoidCallback onRead;
  final VoidCallback onFavorite;
  final VoidCallback onDownload;
  final VoidCallback onCloudFavorite;
  final VoidCallback onFollow;
  final VoidCallback onRate;
  final bool isFavorite;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: isLoading ? null : onRead,
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('开始阅读'),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Action(
              icon: isFavorite ? Icons.star : Icons.star_outline,
              label: isFavorite ? '已收藏' : '收藏',
              onPressed: onFavorite,
            ),
            _Action(
              icon: Icons.download_outlined,
              label: '下载',
              onPressed: onDownload,
            ),
            _Action(
              icon: Icons.cloud_upload_outlined,
              label: '云收藏',
              onPressed: onCloudFavorite,
            ),
            _Action(
              icon: Icons.person_add_alt_1_outlined,
              label: '关注',
              onPressed: onFollow,
            ),
            _Action(
              icon: Icons.star_rate_outlined,
              label: '评分',
              onPressed: onRate,
            ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(
      {required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21),
              const SizedBox(height: 3),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
