import 'gallery_key.dart';

class GallerySearchQuery {
  const GallerySearchQuery({
    required this.source,
    this.keyword = '',
    this.tags = const [],
    this.cursor,
  });

  final SiteSource source;
  final String keyword;
  final List<String> tags;
  final int? cursor;

  String get siteQuery => [keyword, ...tags]
      .where((value) => value.trim().isNotEmpty)
      .map((value) => value.trim())
      .join(' ');
}
