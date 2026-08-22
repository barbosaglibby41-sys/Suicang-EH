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
    final seenLabels = <String>{};
    void addItem(String label, String query, bool follow) {
      if (label.isNotEmpty && seenLabels.add(label)) {
        items.add((label: label, query: query, follow: follow));
      }
    }

    if (gallery.uploader.isNotEmpty) {
      addItem(
        gallery.uploader,
        'uploader:"${gallery.uploader}\$"',
        true,
      );
    }
    final artist = gallery.tags
        .where((tag) => tag.namespace == 'artist')
        .map((tag) => tag.key)
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (artist.isNotEmpty) {
      addItem(artist, 'artist:"$artist\$"', true);
    }
    if (gallery.category.isNotEmpty) {
      addItem(gallery.category, '', false);
    }
    // Publish time is kept in the compact header metadata, not repeated in
    // the statistics grid below.
    if (gallery.postedAt != null) {
      final posted = gallery.postedAt!.toLocal();
      addItem(
        '${posted.year.toString().padLeft(4, '0')}-'
        '${posted.month.toString().padLeft(2, '0')}-'
        '${posted.day.toString().padLeft(2, '0')} '
        '${posted.hour.toString().padLeft(2, '0')}:${posted.minute.toString().padLeft(2, '0')}:${posted.second.toString().padLeft(2, '0')}',
        '',
        false,
      );
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 2),
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
        if (items.length > 1) const SizedBox.shrink(),
      ],
    );
  }
}
