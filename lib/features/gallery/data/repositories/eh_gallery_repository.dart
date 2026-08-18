import 'dart:convert';

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
    int? cursor,
    String? search,
  }) {
    return Uri.https(
      source == SiteSource.eHentai ? 'e-hentai.org' : 'exhentai.org',
      '/',
      {
        if (cursor != null) 'next': '$cursor',
        if (search != null) 'f_search': search,
      },
    );
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
