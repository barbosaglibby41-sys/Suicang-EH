import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../downloads/domain/entities/download_request.dart';
import '../../../downloads/presentation/providers/download_providers.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../favorites/presentation/providers/cloud_favorites_providers.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../providers/gallery_providers.dart';
import '../state/gallery_detail_state.dart';

final galleryDetailNotifierProvider = NotifierProvider.family<
    GalleryDetailNotifier, GalleryDetailState, Gallery>(
  GalleryDetailNotifier.new,
);

class GalleryDetailNotifier extends FamilyNotifier<GalleryDetailState, Gallery> {
  GalleryRepository get _repository => ref.read(galleryRepositoryProvider);

  @override
  GalleryDetailState build(Gallery gallery) => GalleryDetailState(gallery: gallery);

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

  Future<void> setCloudFavorite({required int category, required bool value}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(cloudFavoritesRepositoryProvider).setFavorite(
            gallery: state.gallery,
            category: category,
            value: value,
          );
      state = state.copyWith(isLoading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '账户收藏更新失败。请先登录并确认站点会话。',
      );
    }
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
            DownloadRequest(gallery: detail.gallery, pageUrls: detail.pageLinks),
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
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '详情加载失败。请稍后重试。',
      );
    }
  }
}
