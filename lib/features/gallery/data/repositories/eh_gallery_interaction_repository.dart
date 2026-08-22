import '../../../../core/network/network_exception.dart';
import '../../../../core/network/site_http_client.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_key.dart';
import '../../domain/entities/gallery_comment.dart';
import '../../domain/entities/gallery_metadata.dart';
import '../../domain/repositories/gallery_interaction_repository.dart';
import '../datasources/eh_html_parser.dart';

class EhGalleryInteractionRepository implements GalleryInteractionRepository {
  EhGalleryInteractionRepository({
    required SiteHttpClient client,
    AuthRepository? authRepository,
    EhHtmlParser parser = const EhHtmlParser(),
  })  : _client = client,
        _authRepository = authRepository,
        _parser = parser;

  final SiteHttpClient _client;
  final AuthRepository? _authRepository;
  final EhHtmlParser _parser;

  @override
  Future<GalleryMetadata> rateGallery({
    required Gallery gallery,
    required double rating,
    required GalleryMetadata metadata,
  }) async {
    final detailUrl = gallery.sourceUrl;
    final apiHost = gallery.key.source == SiteSource.eHentai
        ? 'api.e-hentai.org'
        : 'exhentai.org';
    if (detailUrl == null ||
        metadata.ratingToken == null ||
        metadata.apiKey == null ||
        metadata.apiUserId == null ||
        metadata.apiUserId! < 0) {
      throw const NetworkException(
        kind: NetworkFailureKind.authenticationRequired,
        message: 'Rating requires a valid logged-in session.',
      );
    }
    final authRepository = _authRepository;
    if (authRepository == null) {
      throw const NetworkException(
        kind: NetworkFailureKind.authenticationRequired,
        message: 'Rating requires an authenticated account.',
      );
    }
    final cookies = await authRepository.cookiesFor(gallery.key.source);
    final memberIds = cookies
        .where((cookie) => cookie.name == 'ipb_member_id')
        .map((cookie) => int.tryParse(cookie.value))
        .whereType<int>()
        .toList(growable: false);
    final memberId = memberIds.isEmpty ? null : memberIds.first;
    if (memberId == null) {
      throw const NetworkException(
        kind: NetworkFailureKind.authenticationRequired,
        message: 'Rating requires an authenticated account.',
      );
    }
    final response = await _client.postJson(
      Uri.https(apiHost, '/api.php'),
      source: gallery.key.source,
      referer: detailUrl,
      data: {
        'method': 'rategallery',
        'gid': gallery.key.gid,
        'token': metadata.ratingToken,
        'rating': (rating * 2).round(),
        'apiuid': memberId,
        'apikey': metadata.apiKey,
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    final updatedUser =
        double.tryParse('${body['rating_usr'] ?? rating}') ?? rating;
    final average = double.tryParse(
        '${body['rating_avg'] ?? metadata.ratingAverage ?? rating}');
    final count =
        int.tryParse('${body['rating_cnt'] ?? metadata.ratingCount ?? 0}');
    return GalleryMetadata(
      language: metadata.language,
      fileSize: metadata.fileSize,
      favoriteCount: metadata.favoriteCount,
      ratingCount: count,
      torrentUrl: metadata.torrentUrl,
      ratingUser: updatedUser,
      ratingAverage: average,
      hasRated: true,
      ratingToken: metadata.ratingToken,
      apiUserId: metadata.apiUserId,
      apiKey: metadata.apiKey,
    );
  }

  @override
  Future<List<GalleryComment>> voteComment({
    required Gallery gallery,
    required int commentId,
    required bool upvote,
  }) async {
    final detailUrl = gallery.sourceUrl;
    if (detailUrl == null || commentId <= 0) {
      throw const NetworkException(
        kind: NetworkFailureKind.invalidResponse,
        message: 'A valid gallery comment is required.',
      );
    }
    final html = await _client.getText(detailUrl, source: gallery.key.source);
    final token = _parser.commentVoteToken(html);
    if (token == null) {
      throw const NetworkException(
        kind: NetworkFailureKind.authenticationRequired,
        message: 'Comment voting token is unavailable.',
      );
    }
    await _client.postForm(
      detailUrl,
      source: gallery.key.source,
      referer: detailUrl,
      data: {
        'token': token,
        'comment_id': '$commentId',
        'comment_vote': upvote ? '1' : '-1',
      },
    );
    final refreshed =
        await _client.getText(detailUrl, source: gallery.key.source);
    return _parser.comments(refreshed);
  }

  @override
  Future<List<GalleryComment>> postComment({
    required Gallery gallery,
    required String content,
  }) async {
    final detailUrl = gallery.sourceUrl;
    if (detailUrl == null) {
      throw const NetworkException(
        kind: NetworkFailureKind.invalidResponse,
        message: 'A gallery detail URL is required.',
      );
    }
    final trimmed = content.trim();
    if (trimmed.length < 3) {
      throw const NetworkException(
        kind: NetworkFailureKind.parseFailure,
        message: 'Comment must contain at least 3 characters.',
      );
    }
    await _client.postForm(
      detailUrl,
      source: gallery.key.source,
      referer: detailUrl,
      data: {
        'commenttext_new': trimmed,
        'comment_submit_new': 'Post',
      },
    );
    final html = await _client.getText(detailUrl, source: gallery.key.source);
    return _parser.comments(html);
  }
}
