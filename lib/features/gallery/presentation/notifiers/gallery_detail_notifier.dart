import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_exception.dart';

import '../../../downloads/domain/entities/download_request.dart';
import '../../../downloads/presentation/providers/download_providers.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../follows/domain/entities/followed_creator.dart';
import '../../../follows/presentation/providers/followed_creator_providers.dart';
import '../providers/gallery_interaction_providers.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_tag.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../providers/gallery_providers.dart';
import '../state/gallery_detail_state.dart';

final galleryDetailNotifierProvider =
    NotifierProvider.family<GalleryDetailNotifier, GalleryDetailState, Gallery>(
  GalleryDetailNotifier.new,
);

class GalleryDetailNotifier
    extends FamilyNotifier<GalleryDetailState, Gallery> {
  GalleryRepository get _repository => ref.read(galleryRepositoryProvider);

  @override
  GalleryDetailState build(Gallery gallery) =>
      GalleryDetailState(gallery: gallery);

  Future<bool> isFavorite() {
    return ref.read(libraryRepositoryProvider).isFavorite(state.gallery.key);
  }

  Future<void> toggleFavorite() async {
    final repository = ref.read(libraryRepositoryProvider);
    final favorite = await repository.isFavorite(state.gallery.key);
    await repository.setFavorite(state.gallery, value: !favorite);
  }

  Future<void> recordOpened() {
    return ref.read(libraryRepositoryProvider).recordOpened(state.gallery);
  }

  Future<void> followArtistOrUploader(FollowedCreatorKind kind) async {
    final value = kind == FollowedCreatorKind.artist
        ? _artistValue(state.gallery)
        : state.gallery.uploader;
    if (value.isEmpty) return;
    final id =
        '${state.gallery.key.source.storageValue}:${kind.name}:${value.toLowerCase()}';
    final repository = ref.read(followedCreatorRepositoryProvider);
    if (await repository.isFollowing(id)) {
      await repository.unfollow(id);
      return;
    }
    await repository.follow(
      FollowedCreator(
        id: id,
        source: state.gallery.key.source,
        kind: kind,
        value: value,
        displayName: value,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  String _artistValue(Gallery gallery) {
    final tag = gallery.tags.firstWhere(
      (tag) => tag.namespace == 'artist',
      orElse: () => const GalleryTag(namespace: '', key: ''),
    );
    return tag.key;
  }

  Future<void> voteComment({
    required int commentId,
    required bool upvote,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final comments =
          await ref.read(galleryInteractionRepositoryProvider).voteComment(
                gallery: state.gallery,
                commentId: commentId,
                upvote: upvote,
              );
      state = state.copyWith(
          comments: comments, isLoading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '评论投票失败。请确认登录状态后重试。',
      );
    }
  }

  Future<void> postComment(String content) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final comments = await ref
          .read(galleryInteractionRepositoryProvider)
          .postComment(gallery: state.gallery, content: content);
      state = state.copyWith(
        comments: comments,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '评论发送失败。请确认已登录且内容不少于 3 个字符。',
      );
    }
  }

  Future<Uri?> loadTorrentUrl() async {
    final direct = state.metadata.torrentUrl;
    if (direct != null) return direct;
    return _repository.torrentUrl(state.gallery);
  }

  Future<void> enqueueDownload() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _repository.loadDetail(
        state.gallery,
        includePageLinks: true,
      );
      if (detail.pageLinks.isEmpty) {
        throw StateError('No downloadable pages found.');
      }
      await ref.read(downloadRepositoryProvider).enqueue(
            DownloadRequest(
                gallery: detail.gallery, pageUrls: detail.pageLinks),
          );
      state = state.copyWith(
        gallery: detail.gallery,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '无法创建下载任务。请确认站点会话后重试。',
      );
    }
  }

  String _detailError(Object error) {
    if (error is NetworkException) {
      return switch (error.kind) {
        NetworkFailureKind.timeout => '详情请求超时，请稍后重试。',
        NetworkFailureKind.noConnection => '详情网络连接失败，请检查网络后重试。',
        NetworkFailureKind.accessDenied =>
          '详情请求被站点拒绝（HTTP ${error.statusCode ?? 403}）。请重新导入 Cookie 或稍后重试。',
        NetworkFailureKind.authenticationRequired => '详情需要有效站点会话，请重新导入 Cookie。',
        NetworkFailureKind.parseFailure => '详情页面格式异常，未找到有效作品信息。',
        _ =>
          '详情请求失败${error.statusCode == null ? '' : '（HTTP ${error.statusCode}）'}，请稍后重试。',
      };
    }
    if (error is ArgumentError) return '作品地址无效，无法加载详情。';
    return '详情加载失败，请稍后重试。';
  }

  Future<void> load() async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _repository.loadDetail(state.gallery);
      state = state.copyWith(
        gallery: detail.gallery,
        metadata: detail.metadata,
        comments: detail.comments,
        previews: detail.previews,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _detailError(error),
      );
    }
  }
}
