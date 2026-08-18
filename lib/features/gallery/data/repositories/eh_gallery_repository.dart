import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/site_http_client.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_detail.dart';
import '../../domain/entities/gallery_key.dart';
import '../../domain/entities/gallery_page_result.dart';
import '../../domain/entities/gallery_search_query.dart';
import '../../domain/entities/gallery_tag.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../../rankings/domain/entities/ranking_period.dart';
import '../datasources/eh_html_parser.dart';

class EhGalleryRepository implements GalleryRepository {
  EhGalleryRepository({
    required AppDatabase database,
    required SiteHttpClient client,
    EhHtmlParser parser = const EhHtmlParser(),
  })  : _database = database,
        _client = client,
        _parser = parser;

  final AppDatabase _database;
  final SiteHttpClient _client;
  final EhHtmlParser _parser;

  @override
  Future<GalleryPageResult> discover({
    required SiteSource source,
    int? cursor,
  }) async {
    return _loadPage(_buildSiteUri(source: source, cursor: cursor));
  }

  @override
  Future<GalleryPageResult> search(GallerySearchQuery query) async {
    return _loadPage(
      _buildSiteUri(
        source: query.source,
        cursor: query.cursor,
        search: query.siteQuery().isEmpty ? null : query.siteQuery(),
      ),
    );
  }

  @override
  Future<GalleryPageResult> popular({required SiteSource source}) {
    return _loadPage(_buildSiteUri(source: source, path: '/popular'));
  }

  @override
  Future<GalleryPageResult> rankings({
    required SiteSource source,
    required RankingPeriod period,
    int page = 0,
  }) {
    return _loadPage(
      _buildSiteUri(
        source: source,
        path: '/toplist.php',
        queryParameters: {'tl': period.endpointValue, 'p': '$page'},
      ),
    );
  }

  @override
  Future<List<Gallery>> random({
    required SiteSource source,
    int count = 12,
    Set<int> excluding = const {},
  }) async {
    final first = await discover(source: source);
    final maxId = first.galleries.fold<int>(1, (max, gallery) =>
        gallery.key.gid > max ? gallery.key.gid : max);
    final result = <Gallery>[];
    final known = {...excluding};
    final cursors = <int>{};
    var attempts = 0;
    while (result.length < count && attempts < 8) {
      attempts += 1;
      final cursor = _randomCursor(maxId, cursors);
      cursors.add(cursor);
      final page = await discover(source: source, cursor: cursor);
      for (final gallery in page.galleries) {
        if (known.add(gallery.key.gid)) result.add(gallery);
        if (result.length == count) break;
      }
    }
    return result;
  }

  @override
  Future<GalleryDetail> loadDetail(
    Gallery gallery, {
    bool includePageLinks = false,
  }) async {
    final sourceUri = gallery.sourceUrl;
    if (sourceUri == null) {
      throw ArgumentError.value(gallery, 'gallery', 'A source URL is required.');
    }
    final html = await _client.getText(sourceUri, source: gallery.key.source);
    final detail = _parser.detail(
      html: html,
      fallback: gallery,
      sourceUri: sourceUri,
      includePageLinks: includePageLinks,
    );
    await upsert(detail.gallery);
    return detail;
  }

  @override
  Future<Uri> resolveImageUrl(
    Uri pageUrl, {
    Uri? referer,
    bool forceRefresh = false,
  }) async {
    final source = _sourceFromHost(pageUrl.host);
    final uri = forceRefresh ? _withRefreshToken(pageUrl) : pageUrl;
    final html = await _client.getText(uri, source: source, referer: referer);
    return _parser.resolveImageUrl(html);
  }

  @override
  Future<Uri?> torrentUrl(Gallery gallery) async {
    final sourceUrl = gallery.sourceUrl;
    if (sourceUrl == null) return null;
    final parts = sourceUrl.pathSegments;
    if (parts.length < 3) return null;
    final gid = parts[1];
    final token = parts[2];
    final endpoint = _buildSiteUri(
      source: gallery.key.source,
      path: '/gallerytorrents.php',
      queryParameters: {'gid': gid, 't': token},
    );
    final html = await _client.getText(endpoint, source: gallery.key.source);
    final raw = RegExp(r'''href=["'](https?://[^"']+\.torrent)["']''', caseSensitive: false)
        .firstMatch(html)
        ?.group(1);
    return raw == null ? null : Uri.tryParse(raw.replaceAll('&amp;', '&'));
  }

  @override
  Future<Gallery?> findByKey(GalleryKey key) async {
    final row = await (_database.select(_database.galleries)
          ..where(
            (table) =>
                table.source.equals(key.source.storageValue) &
                table.gid.equals(key.gid),
          ))
        .getSingleOrNull();
    return row == null ? null : _galleryFromRow(row);
  }

  @override
  Future<void> upsert(Gallery gallery) {
    return _database.into(_database.galleries).insertOnConflictUpdate(
          GalleriesCompanion.insert(
            source: gallery.key.source.storageValue,
            gid: gallery.key.gid,
            title: gallery.title,
            uploader: Value(gallery.uploader),
            category: Value(gallery.category),
            thumbnailUrl: Value(gallery.thumbnailUrl?.toString()),
            sourceUrl: Value(gallery.sourceUrl?.toString()),
            pageCount: Value(gallery.pageCount),
            tagsJson: Value(
              jsonEncode([
                for (final tag in gallery.tags)
                  {
                    'namespace': tag.namespace,
                    'key': tag.key,
                    'translatedName': tag.translatedName,
                  },
              ]),
            ),
            rating: Value(gallery.rating),
            postedAt: Value(gallery.postedAt),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<GalleryPageResult> _loadPage(Uri uri) async {
    final source = _sourceFromHost(uri.host);
    final html = await _client.getText(uri, source: source);
    final result = _parser.galleriesPage(
      html: html,
      source: source,
      baseUri: uri,
    );
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.galleries,
        [
          for (final gallery in result.galleries)
            _galleryCompanion(gallery),
        ],
      );
    });
    return result;
  }

  Uri _buildSiteUri({
    required SiteSource source,
    String path = '/',
    int? cursor,
    String? search,
    Map<String, String>? queryParameters,
  }) {
    return Uri.https(
      source == SiteSource.eHentai ? 'e-hentai.org' : 'exhentai.org',
      path,
      {
        ...?queryParameters,
        if (cursor != null) 'next': '$cursor',
        if (search != null) 'f_search': search,
      },
    );
  }

  int _randomCursor(int maxId, Set<int> used) {
    final random = Random.secure();
    for (var attempt = 0; attempt < 20; attempt++) {
      final cursor = 1 + random.nextInt(maxId);
      if (!used.contains(cursor)) return cursor;
    }
    return 1;
  }

  SiteSource _sourceFromHost(String host) =>
      host.toLowerCase().contains('exhentai')
          ? SiteSource.exHentai
          : SiteSource.eHentai;

  Uri _withRefreshToken(Uri url) => url.replace(
        queryParameters: {
          ...url.queryParameters,
          'nl': '${DateTime.now().microsecondsSinceEpoch}',
        },
      );

  GalleriesCompanion _galleryCompanion(Gallery gallery) => GalleriesCompanion.insert(
        source: gallery.key.source.storageValue,
        gid: gallery.key.gid,
        title: gallery.title,
        uploader: Value(gallery.uploader),
        category: Value(gallery.category),
        thumbnailUrl: Value(gallery.thumbnailUrl?.toString()),
        sourceUrl: Value(gallery.sourceUrl?.toString()),
        pageCount: Value(gallery.pageCount),
        tagsJson: Value(_encodeTags(gallery.tags)),
        rating: Value(gallery.rating),
        postedAt: Value(gallery.postedAt),
        updatedAt: DateTime.now().toUtc(),
      );

  Gallery _galleryFromRow(GalleryRow row) => Gallery(
        key: GalleryKey(
          source: SiteSource.fromStorageValue(row.source),
          gid: row.gid,
        ),
        title: row.title,
        uploader: row.uploader,
        category: row.category,
        thumbnailUrl: Uri.tryParse(row.thumbnailUrl ?? ''),
        sourceUrl: Uri.tryParse(row.sourceUrl ?? ''),
        pageCount: row.pageCount,
        rating: row.rating,
        postedAt: row.postedAt,
        tags: _decodeTags(row.tagsJson),
      );

  String _encodeTags(Iterable<GalleryTag> tags) => jsonEncode([
        for (final tag in tags)
          {
            'namespace': tag.namespace,
            'key': tag.key,
            'translatedName': tag.translatedName,
          },
      ]);

  List<GalleryTag> _decodeTags(String value) {
    final decoded = jsonDecode(value) as List<dynamic>;
    return [
      for (final entry in decoded.whereType<Map<String, dynamic>>())
        GalleryTag(
          namespace: entry['namespace'] as String? ?? 'other',
          key: entry['key'] as String? ?? '',
          translatedName: entry['translatedName'] as String?,
        ),
    ];
  }
}
