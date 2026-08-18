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
