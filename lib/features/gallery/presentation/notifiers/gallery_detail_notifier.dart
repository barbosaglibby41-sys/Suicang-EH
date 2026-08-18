import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> load() async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _repository.loadDetail(state.gallery);
      state = state.copyWith(
        gallery: detail.gallery,
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
