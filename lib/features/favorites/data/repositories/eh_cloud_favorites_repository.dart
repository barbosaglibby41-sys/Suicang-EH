import '../../../../core/network/site_http_client.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../domain/entities/cloud_favorite_category.dart';
import '../../domain/entities/cloud_favorites_page.dart';
import '../../domain/repositories/cloud_favorites_repository.dart';
import '../datasources/cloud_favorites_parser.dart';

class EhCloudFavoritesRepository implements CloudFavoritesRepository {
  EhCloudFavoritesRepository({
    required SiteHttpClient client,
    CloudFavoritesParser parser = const CloudFavoritesParser(),
  })  : _client = client,
        _parser = parser;

  final SiteHttpClient _client;
  final CloudFavoritesParser _parser;

  @override
  List<CloudFavoriteCategory> defaultCategories() => [
        for (var index = 0; index < 10; index++)
          CloudFavoriteCategory(id: index, name: '收藏夹 ${index + 1}'),
      ];

  @override
  Future<CloudFavoritesPage> load({
    required SiteSource source,
    required int category,
    Uri? pageUrl,
  }) async {
    final base = _base(source);
    final target = pageUrl ?? base.replace(
      path: '/favorites.php',
      queryParameters: {'favcat': '$category'},
    );
    final html = await _client.getText(target, source: source);
    return _parser.parse(html: html, source: source, baseUri: base);
  }

  @override
  Future<void> setFavorite({
    required Gallery gallery,
    required int category,
    required bool value,
  }) async {
    final detailUrl = gallery.sourceUrl;
    if (detailUrl == null) {
      throw ArgumentError.value(gallery, 'gallery', 'Gallery source URL is required.');
    }
    final source = gallery.key.source;
    final html = await _client.getText(detailUrl, source: source);
    final token = _favoriteToken(html);
    final endpoint = _base(source).replace(
      path: '/gallerypopups.php',
      queryParameters: {
        'gid': '${gallery.key.gid}',
        't': token ?? '',
        'act': 'addfav',
      },
    );
    await _client.postForm(
      endpoint,
      source: source,
      referer: detailUrl,
      data: {
        'favcat': value ? '$category' : '-1',
        'favnote': '',
        'submit': 'Apply Changes',
        'update': '1',
      },
    );
  }

  Uri _base(SiteSource source) => Uri.https(
        source == SiteSource.eHentai ? 'e-hentai.org' : 'exhentai.org',
        '/',
      );

  String? _favoriteToken(String html) {
    final patterns = [
      r'''gallerypopups\.php\?gid=\d+&t=([0-9a-zA-Z]+)''',
      r'''[?&]t=([0-9a-zA-Z]+)''',
      r'''name=["']token["'][^>]+value=["']([^"']+)''',
    ];
    for (final pattern in patterns) {
      final token = RegExp(pattern, caseSensitive: false).firstMatch(html)?.group(1);
      if (token != null) return token;
    }
    return null;
  }
}
