import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/repositories/eh_cloud_favorites_repository.dart';
import '../../domain/entities/cloud_favorite_category.dart';
import '../../domain/repositories/cloud_favorites_repository.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';

class CloudFavoriteStatus {
  const CloudFavoriteStatus({
    required this.category,
    required this.isFavorite,
  });

  final int category;
  final bool isFavorite;
}

final cloudFavoritesRepositoryProvider =
    Provider<CloudFavoritesRepository>((ref) {
  return EhCloudFavoritesRepository(client: ref.watch(siteHttpClientProvider));
});

final cloudFavoritesNotifierProvider =
    NotifierProvider<CloudFavoritesNotifier, CloudFavoritesState>(
        CloudFavoritesNotifier.new);

class CloudFavoritesState {
  const CloudFavoritesState({
    required this.source,
    this.category = 0,
    this.categories = const [],
    this.galleries = const [],
    this.nextUrl,
    this.isLoading = false,
    this.errorMessage,
  });

  final SiteSource source;
  final int category;
  final List<CloudFavoriteCategory> categories;
  final List<Gallery> galleries;
  final Uri? nextUrl;
  final bool isLoading;
  final String? errorMessage;

  CloudFavoritesState copyWith({
    SiteSource? source,
    int? category,
    List<CloudFavoriteCategory>? categories,
    List<Gallery>? galleries,
    Uri? nextUrl,
    bool clearNextUrl = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CloudFavoritesState(
        source: source ?? this.source,
        category: category ?? this.category,
        categories: categories ?? this.categories,
        galleries: galleries ?? this.galleries,
        nextUrl: clearNextUrl ? null : nextUrl ?? this.nextUrl,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

class CloudFavoritesNotifier extends Notifier<CloudFavoritesState> {
  @override
  CloudFavoritesState build() =>
      const CloudFavoritesState(source: SiteSource.eHentai);

  bool contains(Gallery gallery) =>
      state.galleries.any((item) => item.key == gallery.key);

  Future<void> setFavorite({
    required Gallery gallery,
    required int category,
    required bool value,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(cloudFavoritesRepositoryProvider).setFavorite(
            gallery: gallery,
            category: category,
            value: value,
          );
      final updated = [...state.galleries];
      if (value && category == state.category &&
          !updated.any((item) => item.key == gallery.key)) {
        updated.insert(0, gallery);
      } else if (!value) {
        updated.removeWhere((item) => item.key == gallery.key);
      }
      state = state.copyWith(galleries: updated, isLoading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '账户收藏更新失败。请确认登录状态后重试。',
      );
    }
  }

  Future<void> load({int? category, bool more = false}) async {
    if (state.isLoading) return;
    final selected = category ?? state.category;
    final pageUrl = more ? state.nextUrl : null;
    if (more && pageUrl == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await ref.read(cloudFavoritesRepositoryProvider).load(
            source: state.source,
            category: selected,
            pageUrl: pageUrl,
          );
      final known = state.galleries.map((gallery) => gallery.key).toSet();
      final galleries = more
          ? [
              ...state.galleries,
              ...page.galleries.where((gallery) => known.add(gallery.key))
            ]
          : page.galleries;
      state = state.copyWith(
        category: selected,
        categories: page.categories.isEmpty
            ? ref.read(cloudFavoritesRepositoryProvider).defaultCategories()
            : page.categories,
        galleries: galleries,
        nextUrl: page.nextUrl,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '账户收藏加载失败。请确认账户登录状态后重试。',
      );
    }
  }
}
