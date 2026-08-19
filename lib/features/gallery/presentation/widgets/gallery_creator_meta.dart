import 'package:flutter/material.dart';

import '../../domain/entities/gallery.dart';

class GalleryCreatorMeta extends StatelessWidget {
  const GalleryCreatorMeta({
    required this.gallery,
    required this.onSearch,
    required this.onFollow,
    super.key,
  });

  final Gallery gallery;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onFollow;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, String query, bool follow})>[];
    if (gallery.uploader.isNotEmpty) {
      items.add((label: gallery.uploader, query: 'uploader:"${gallery.uploader}\$"', follow: true));
    }
    final artist = gallery.tags
        .where((tag) => tag.namespace == 'artist')
        .map((tag) => tag.key)
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (artist.isNotEmpty) {
      items.add((label: artist, query: 'artist:"$artist\$"', follow: true));
    }
    if (gallery.category.isNotEmpty) {
      items.add((label: gallery.category, query: '', follow: false));
    }
    if (gallery.pageCount > 0) {
      items.add((label: '${gallery.pageCount} 页', query: '', follow: false));
    }
    if (gallery.postedAt != null) {
      items.add((
        label: '${gallery.postedAt!.toLocal().year.toString().padLeft(4, '0')}-'
            '${gallery.postedAt!.toLocal().month.toString().padLeft(2, '0')}-'
            '${gallery.postedAt!.toLocal().day.toString().padLeft(2, '0')} '
            '${gallery.postedAt!.toLocal().hour.toString().padLeft(2, '0')}:'
            '${gallery.postedAt!.toLocal().minute.toString().padLeft(2, '0')}:'
            '${gallery.postedAt!.toLocal().second.toString().padLeft(2, '0')}',
        query: '',
        follow: false,
      ));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 3,
      children: [
        for (final item in items)
          item.query.isEmpty
              ? Text(item.label, style: Theme.of(context).textTheme.bodySmall)
              : GestureDetector(
                  onLongPress: () => onFollow(item.label),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSearch(item.query),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dotted,
                            ),
                      ),
                    ),
                  ),
                ),
        if (items.length > 1)
          const SizedBox.shrink(),
      ],
    );
  }
}
