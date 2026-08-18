import '../../../../core/network/network_exception.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_detail.dart';
import '../../domain/entities/gallery_key.dart';
import '../../domain/entities/gallery_page_result.dart';
import '../../domain/entities/gallery_tag.dart';
import '../../domain/entities/gallery_comment.dart';
import '../../domain/entities/gallery_metadata.dart';
import '../../domain/entities/page_preview.dart';

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
    final metadataById = _listMetadata(html, baseUri);
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
      final metadata = metadataById[gid] ?? const _ListMetadata();
      galleries.add(
        Gallery(
          key: GalleryKey(source: source, gid: gid),
          title: title,
          uploader: metadata.uploader,
          category: metadata.category,
          pageCount: metadata.pageCount,
          sourceUrl: _resolve(baseUri, _decode(match.group(1) ?? '')),
          thumbnailUrl: metadata.thumbnailUrl,
          rating: metadata.rating,
          postedAt: metadata.postedAt,
          tags: metadata.tags,
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
    final language = _detailValue(html, 'Language');
    final fileSize = _detailValue(html, 'File Size');
    final favoriteCount = int.tryParse(
      (_first(r'''id=["']favcount["'][^>]*>\s*([0-9,]+)\s+times''', html) ?? '')
          .replaceAll(',', ''),
    );
    final ratingCount = int.tryParse(
      (_first(r'''id=["']rating_count["'][^>]*>\s*([0-9,]+)\s*</''', html) ?? '')
          .replaceAll(',', ''),
    );
    final torrent = _first(r'''href=["'](https?://[^"']+\.torrent)["']''', html);
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
      metadata: GalleryMetadata(
        language: language,
        fileSize: fileSize,
        favoriteCount: favoriteCount,
        ratingCount: ratingCount,
        torrentUrl: torrent == null ? null : Uri.tryParse(_decode(torrent)),
      ),
      comments: comments(html),
      previews: previews(html, sourceUri),
    );
  }

  List<PagePreview> previews(String html, Uri baseUri, {int limit = 20}) {
    final start = html.indexOf('id="gdt"');
    if (start < 0) return const [];
    final end = html.indexOf('id="gdo"', start);
    final region = html.substring(start, end < 0 ? html.length : end);
    final expression = RegExp(
      r'''<a href=["']([^"']*/s/[^"']+)["'][^>]*><div title=["']Page (\d+):[^"']*["'] style=["'][^"']*width:(\d+)px;height:(\d+)px;background:transparent url\(([^)]+)\)\s*(-?\d+)px\s+(-?\d+)''',
      caseSensitive: false,
    );
    final seen = <int>{};
    final result = <PagePreview>[];
    for (final match in expression.allMatches(region)) {
      final page = int.tryParse(match.group(2) ?? '');
      final width = int.tryParse(match.group(3) ?? '');
      final height = int.tryParse(match.group(4) ?? '');
      final x = int.tryParse(match.group(6) ?? '');
      final y = int.tryParse(match.group(7) ?? '');
      if (page == null || width == null || height == null || x == null || y == null || !seen.add(page)) continue;
      final sprite = Uri.tryParse(_decode(match.group(5) ?? ''));
      if (sprite == null) continue;
      result.add(PagePreview(
        page: page,
        spriteUrl: sprite,
        xOffset: x.abs(),
        yOffset: y.abs(),
        width: width,
        height: height,
        pageUrl: baseUri.resolve(_decode(match.group(1) ?? '')),
      ));
      if (result.length == limit) break;
    }
    result.sort((left, right) => left.page.compareTo(right.page));
    return result;
  }

  List<GalleryComment> comments(String html) {
    final start = html.indexOf('id="cdiv"');
    if (start < 0) return const [];
    final end = html.indexOf('id="chd"', start);
    final region = html.substring(start, end < 0 ? html.length : end);
    final blocks = RegExp(
      r'''<div class=["']c1["'].*?(?=<div class=["']c1["']|<div id=["']chd["']|$)''',
      caseSensitive: false,
      dotAll: true,
    );
    final result = <GalleryComment>[];
    for (final blockMatch in blocks.allMatches(region)) {
      final block = blockMatch.group(0) ?? '';
      final content = _first(r'''<div class=["']c6["'] id=["']comment_\d+["']>(.*?)</div>''', block);
      if (content == null) continue;
      final id = int.tryParse(_first(r'''id=["']comment_(\d+)["']''', block) ?? '') ?? 0;
      final author = _first(r'''by:?\s*&nbsp;\s*<a[^>]*>(.*?)</a>''', block);
      final posted = _first(r'''Posted on (.*?) by''', block);
      final score = int.tryParse(_first(r'''<span id=["']comment_score_\d+["'][^>]*>([+-]?\d+)</span>''', block) ?? '');
      final votes = _first(r'''<div class=["']c7["'] id=["']cvotes_\d+["'][^>]*>(.*?)</div>''', block);
      result.add(GalleryComment(
        id: id,
        author: author == null ? '匿名' : _clean(author),
        postedAt: posted == null ? '' : _clean(posted),
        score: score,
        isUploader: block.contains('Uploader Comment'),
        content: _htmlToText(content),
        votes: votes == null ? null : _clean(votes),
      ));
    }
    return result;
  }

  String? _detailValue(String html, String label) {
    final expression = RegExp(
      '''<td[^>]*class=["']gdt1["'][^>]*>\\s*$label:\\s*</td>\\s*<td[^>]*class=["']gdt2["'][^>]*>(.*?)</td>''',
      caseSensitive: false,
      dotAll: true,
    );
    final value = expression.firstMatch(html)?.group(1);
    return value == null ? null : _clean(value);
  }

  String _htmlToText(String html) => _decode(html)
      .replaceAll(RegExp(r'<br[^>]*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

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

  int? toplistNextPage(String html, int currentPage) {
    final pages = RegExp(
      r'''href=["'][^"']*toplist\.php[^"']*[?&]p=(\d+)[^"']*["']''',
      caseSensitive: false,
    ).allMatches(html).map((match) => int.tryParse(match.group(1) ?? '')).whereType<int>();
    final next = pages.where((page) => page > currentPage).toList()..sort();
    return next.isEmpty ? null : next.first;
  }

  int? _nextCursor(String html) {
    final value = _first(r'''class=["'][^"']*dnext[^"']*["'][^>]+href=["']([^"']+)''', html);
    if (value == null) {
      return null;
    }
    return int.tryParse(Uri.tryParse(_decode(value))?.queryParameters['next'] ?? '');
  }

  Map<int, _ListMetadata> _listMetadata(String html, Uri baseUri) {
    final ids = RegExp(r'''id=["']it(\d+)["']''', caseSensitive: false);
    final result = <int, _ListMetadata>{};
    for (final match in ids.allMatches(html)) {
      final gid = int.tryParse(match.group(1) ?? '');
      if (gid == null) continue;
      final start = match.start;
      final rowEnd = html.indexOf('</tr>', start);
      final end = rowEnd < 0 ? html.length : rowEnd;
      final row = html.substring(start, end);
      final rawImage = _first(r'''data-src=["']([^"']+)["']''', row) ??
          _first(r'''<img[^>]+src=["']([^"']+)["']''', row);
      final tags = RegExp(
        r'''class=["'][^"']*gt[^"']*["'][^>]*title=["']([^"']+)["']''',
        caseSensitive: false,
      ).allMatches(row).map((value) => GalleryTag.parse(_decode(value.group(1) ?? ''))).toList();
      result[gid] = _ListMetadata(
        thumbnailUrl: rawImage == null ? null : _resolve(baseUri, _decode(rawImage)),
        pageCount: int.tryParse(
              (_first(r'''([0-9,]+)\s+pages''', row) ?? '').replaceAll(',', ''),
            ) ??
            0,
        category: _clean(_first(r'''class=["'][^"']*cn[^"']*["'][^>]*>(.*?)</div>''', row) ?? ''),
        uploader: _clean(
          _first(r'''class=["']gl4c[^"']*["'][^>]*>.*?<a[^>]*>(.*?)</a>''', row) ?? '',
        ),
        postedAt: DateTime.tryParse(
          _clean(_first(r'''id=["']postedpop_\d+["'][^>]*>(.*?)</div>''', row) ?? ''),
        ),
        rating: double.tryParse(_first(r'''Average:\s*([0-9]+(?:\.[0-9]+)?)''', row) ?? ''),
        tags: tags,
      );
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

class _ListMetadata {
  const _ListMetadata({
    this.thumbnailUrl,
    this.pageCount = 0,
    this.category = '',
    this.uploader = '',
    this.postedAt,
    this.rating,
    this.tags = const [],
  });

  final Uri? thumbnailUrl;
  final int pageCount;
  final String category;
  final String uploader;
  final DateTime? postedAt;
  final double? rating;
  final List<GalleryTag> tags;
}
