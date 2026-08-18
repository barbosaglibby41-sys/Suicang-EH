import '../../../../core/network/network_exception.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_detail.dart';
import '../../domain/entities/gallery_key.dart';
import '../../domain/entities/gallery_page_result.dart';
import '../../domain/entities/gallery_tag.dart';

class EhHtmlParser {
  const EhHtmlParser();

  GalleryPageResult galleriesPage({
    required String html,
    required SiteSource source,
    required Uri baseUri,
  }) {
    final cards = RegExp(
      r'''<a[^>]+href=["']([^"']*/g/(\d+)/[^"']+)["'][^>]*>.*?<div[^>]+class=["'][^"']*glink[^"']*["'][^>]*>(.*?)</div>''',
      caseSensitive: false,
      dotAll: true,
    );
    final thumbnailById = _thumbnailMap(html, baseUri);
    final seen = <int>{};
    final galleries = <Gallery>[];

    for (final match in cards.allMatches(html)) {
      final gid = int.tryParse(match.group(2) ?? '');
      if (gid == null || !seen.add(gid)) {
        continue;
      }
      final title = _clean(match.group(3) ?? '');
      if (title.isEmpty) {
        continue;
      }
      galleries.add(
        Gallery(
          key: GalleryKey(source: source, gid: gid),
          title: title,
          pageCount: 0,
          sourceUrl: _resolve(baseUri, _decode(match.group(1) ?? '')),
          thumbnailUrl: thumbnailById[gid],
        ),
      );
    }
    return GalleryPageResult(
      galleries: galleries,
      nextCursor: _nextCursor(html),
    );
  }

  GalleryDetail detail({
    required String html,
    required Gallery fallback,
    required Uri sourceUri,
    required bool includePageLinks,
  }) {
    final title = _first(r'''id=["']gn["'][^>]*>(.*?)</''', html);
    final category = _first(
      r'''id=["']gdc["'][^>]*>.*?<a[^>]*>(.*?)</a>''',
      html,
    );
    final uploader = _first(
      r'''id=["']gdn["'][^>]*>.*?<a[^>]*>(.*?)</a>''',
      html,
    );
    final pages = _first(r'([0-9,]+)\s+pages', html);
    final cover = _first(r'url\((https?[^)]+)\)', html);
    final rawTags = RegExp(
      r'''id=["']ta_([^"']+)["']''',
      caseSensitive: false,
    ).allMatches(html).map((match) => _decode(match.group(1) ?? ''));
    final uniqueTags = rawTags
        .map(GalleryTag.parse)
        .fold(<String, GalleryTag>{}, (tags, tag) {
      tags[tag.rawName] = tag;
      return tags;
    }).values.toList()
      ..sort((left, right) => left.rawName.compareTo(right.rawName));

    final gallery = fallback.copyWith(
      title: title == null ? null : _clean(title),
      category: category == null ? null : _clean(category),
      uploader: uploader == null ? null : _clean(uploader),
      thumbnailUrl: cover == null ? null : Uri.tryParse(_decode(cover)),
      pageCount: int.tryParse((pages ?? '').replaceAll(',', '')),
      tags: uniqueTags.isEmpty ? fallback.tags : uniqueTags,
    );
    return GalleryDetail(
      gallery: gallery,
      pageLinks: includePageLinks ? imagePageLinks(html, sourceUri) : const [],
    );
  }

  List<Uri> imagePageLinks(String html, Uri baseUri) {
    final expression = RegExp(
      r'''href=["']([^"']*s/[0-9a-zA-Z]+/[0-9]+-[0-9]+)["']''',
      caseSensitive: false,
    );
    final values = <String, Uri>{};
    for (final match in expression.allMatches(html)) {
      final resolved = _resolve(baseUri, match.group(1) ?? '');
      if (resolved != null) {
        values[resolved.toString()] = resolved;
      }
    }
    final links = values.values.toList()
      ..sort((left, right) => _pageNumber(left).compareTo(_pageNumber(right)));
    return links;
  }

  Uri resolveImageUrl(String html) {
    final value = _first(r'''id=["']img["'][^>]+src=["']([^"']+)["']''', html);
    final uri = value == null ? null : Uri.tryParse(_decode(value));
    if (uri == null) {
      throw const NetworkException(
        kind: NetworkFailureKind.parseFailure,
        message: 'The page does not contain a readable image URL.',
      );
    }
    return uri;
  }

  int? _nextCursor(String html) {
    final value = _first(r'''class=["'][^"']*dnext[^"']*["'][^>]+href=["']([^"']+)''', html);
    if (value == null) {
      return null;
    }
    return int.tryParse(Uri.tryParse(_decode(value))?.queryParameters['next'] ?? '');
  }

  Map<int, Uri> _thumbnailMap(String html, Uri baseUri) {
    final expression = RegExp(
      r'''<a[^>]+href=["'][^"']*/g/(\d+)/[^"']+["'][^>]*>\s*<img[^>]+(?:data-src|src)=["']([^"']+)["']''',
      caseSensitive: false,
      dotAll: true,
    );
    final result = <int, Uri>{};
    for (final match in expression.allMatches(html)) {
      final gid = int.tryParse(match.group(1) ?? '');
      final uri = _resolve(baseUri, _decode(match.group(2) ?? ''));
      if (gid != null && uri != null) {
        result[gid] = uri;
      }
    }
    return result;
  }

  String? _first(String pattern, String text) {
    return RegExp(pattern, caseSensitive: false, dotAll: true)
        .firstMatch(text)
        ?.group(1);
  }

  Uri? _resolve(Uri baseUri, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return baseUri.resolve(normalized);
  }

  int _pageNumber(Uri uri) {
    final segment = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    final dash = segment.lastIndexOf('-');
    return dash < 0 ? 1 << 30 : int.tryParse(segment.substring(dash + 1)) ?? 1 << 30;
  }

  String _clean(String value) => _decode(value)
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _decode(String value) => value
      .replaceAll('&amp;', '&')
      .replaceAll('&#039;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&#x27;', "'");
}
