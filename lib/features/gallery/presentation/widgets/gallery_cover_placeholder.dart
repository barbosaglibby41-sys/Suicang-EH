import 'package:flutter/material.dart';

import '../../domain/entities/gallery.dart';

class GalleryCoverPlaceholder extends StatelessWidget {
  const GalleryCoverPlaceholder({
    required this.gallery,
    super.key,
  });

  final Gallery gallery;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      image: true,
      label: '作品封面不可用：${gallery.title}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox.expand(
          child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_stories_outlined,
                  color: scheme.onSecondaryContainer),
              const Spacer(),
              Text(
                gallery.category.isEmpty
                    ? 'GALLERY'
                    : gallery.category.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
