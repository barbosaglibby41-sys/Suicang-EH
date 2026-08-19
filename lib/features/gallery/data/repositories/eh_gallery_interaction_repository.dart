import 'package:dio/dio.dart';

import '../../../../core/network/network_exception.dart';
import '../../../../core/network/site_http_client.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_comment.dart';
import '../../domain/repositories/gallery_interaction_repository.dart';
import '../datasources/eh_html_parser.dart';

class EhGalleryInteractionRepository implements GalleryInteractionRepository {
  EhGalleryInteractionRepository({
    required SiteHttpClient client,
    EhHtmlParser parser = const EhHtmlParser(),
  })  : _client = client,
        _parser = parser;

  final SiteHttpClient _client;
  final EhHtmlParser _parser;

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
