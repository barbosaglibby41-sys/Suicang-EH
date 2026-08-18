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

  String siteQuery({String Function(String value)? translate}) => [keyword, ...tags]
      .where((value) => value.trim().isNotEmpty)
      .map((value) => value.trim())
      .map(translate ?? _identity)
      .join(' ');

  static String _identity(String value) => value;
}
