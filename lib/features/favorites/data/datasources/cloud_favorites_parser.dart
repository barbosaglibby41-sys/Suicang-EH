import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../domain/entities/cloud_favorite_category.dart';
import '../../domain/entities/cloud_favorites_page.dart';

class CloudFavoritesParser {
  const CloudFavoritesParser();

  CloudFavoritesPage parse({
    required String html,
    required SiteSource source,
    required Uri baseUri,
  }) {
    final categories = _categories(html);
    final galleries = _galleries(html, source, baseUri);
    return CloudFavoritesPage(
      categories: categories,
      galleries: galleries,
      nextUrl: _nextUrl(html, baseUri),
    );
  }

  List<CloudFavoriteCategory> _categories(String html) {
    final output = <int, CloudFavoriteCategory>{};
    final options = RegExp(
      r'''<option[^>]+value=["'](\d+)["'][^>]*>(.*?)</option>''',
      caseSensitive: false,
      dotAll: true,
    );
    final folders = RegExp(
      r'''<a[^>]+href=["'][^"']*[?&]favcat=(\d+)[^"']*["'][^>]*>(.*?)</a>''',
      caseSensitive: false,
      dotAll: true,
    );
    for (final match in options.allMatches(html)) {
      final id = int.tryParse(match.group(1) ?? '');
      final name =
          _clean(match.group(2) ?? '').replaceFirst(RegExp(r'^\d+\s*'), '');
      if (id != null && id >= 0 && id <= 9 && name.isNotEmpty) {
        output[id] = CloudFavoriteCategory(id: id, name: name);
      }
    }
    for (final match in folders.allMatches(html)) {
      final id = int.tryParse(match.group(1) ?? '');
      final name =
          _clean(match.group(2) ?? '').replaceFirst(RegExp(r'^\d+\s*'), '');
      if (id != null &&
          id >= 0 &&
          id <= 9 &&
          name.isNotEmpty &&
          !output.containsKey(id)) {
        output[id] = CloudFavoriteCategory(id: id, name: name);
      }
    }
    return output.values.toList()
      ..sort((left, right) => left.id.compareTo(right.id));
  }

  List<Gallery> _galleries(String html, SiteSource source, Uri baseUri) {
    final anchors = RegExp(
      r'''<a[^>]+href=["']([^"']*/g/(\d+)/[^"']+)["'][^>]*>(.*?)</a>''',
      caseSensitive: false,
      dotAll: true,
    );
    final seen = <int>{};
    final output = <Gallery>[];
    for (final match in anchors.allMatches(html)) {
      final gid = int.tryParse(match.group(2) ?? '');
      if (gid == null || !seen.add(gid)) continue;
      final body = match.group(3) ?? '';
      final titleMatch = RegExp(
        r'''class=["'][^"']*(?:glink|glname)[^"']*["'][^>]*>(.*?)</(?:div|a)>''',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(body);
      final title = _clean(titleMatch?.group(1) ?? body);
      if (title.isEmpty) continue;
      final thumbnail =
          RegExp(r'''(?:data-src|src)=["']([^"']+)["']''', caseSensitive: false)
              .firstMatch(body)
              ?.group(1);
      output.add(Gallery(
        key: GalleryKey(source: source, gid: gid),
        title: title,
        pageCount: 0,
        sourceUrl: baseUri.resolve(_decode(match.group(1) ?? '')),
        thumbnailUrl:
            thumbnail == null ? null : baseUri.resolve(_decode(thumbnail)),
      ));
    }
    return output;
  }

  Uri? _nextUrl(String html, Uri baseUri) {
    final match = RegExp(
      r'''<a[^>]+class=["'][^"']*dnext[^"']*["'][^>]+href=["']([^"']+)''',
      caseSensitive: false,
    ).firstMatch(html);
    return match == null
        ? null
        : baseUri.resolve(_decode(match.group(1) ?? ''));
  }

  String _clean(String value) => _decode(value)
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _decode(String value) => value
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&#x27;', "'");
}
