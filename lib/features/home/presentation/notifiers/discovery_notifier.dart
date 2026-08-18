import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../gallery/domain/entities/gallery_search_query.dart';
import '../../../gallery/domain/repositories/gallery_repository.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../../tags/presentation/providers/tag_translation_providers.dart';
import '../../../search/presentation/providers/search_history_providers.dart';
import '../state/discovery_state.dart';

final discoveryNotifierProvider =
    NotifierProvider<DiscoveryNotifier, DiscoveryState>(DiscoveryNotifier.new);

class DiscoveryNotifier extends Notifier<DiscoveryState> {
  GalleryRepository get _repository => ref.read(galleryRepositoryProvider);

  String _translate(String value) {
    final repository = ref.read(tagTranslationRepositoryProvider);
    return repository.isReady ? repository.translateQuery(value) : value;
  }

  @override
  DiscoveryState build() => const DiscoveryState(source: SiteSource.eHentai);

  Future<void> load({bool force = false}) async {
    if (state.isLoading || (state.galleries.isNotEmpty && !force)) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.discover(source: state.source);
      state = state.copyWith(
        galleries: result.galleries,
        nextCursor: result.nextCursor,
        isLoading: false,
        query: '',
        isSearch: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '无法加载发现内容。请检查网络和站点会话后重试。',
      );
    }
  }

  Future<void> loadPopular() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.popular(source: state.source);
      state = state.copyWith(
        galleries: result.galleries,
        nextCursor: result.nextCursor,
        isLoading: false,
        query: '',
        isSearch: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '无法加载热门内容。',
      );
    }
  }

  Future<void> loadRandom() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.random(
        source: state.source,
        excluding: state.galleries.map((gallery) => gallery.key.gid).toSet(),
      );
      state = state.copyWith(
        galleries: result,
        clearNextCursor: true,
        isLoading: false,
        query: '',
        isSearch: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '随机发现失败。',
      );
    }
  }

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      await load(force: true);
      return;
    }
    final tagRepository = ref.read(tagTranslationRepositoryProvider);
    if (!tagRepository.isReady) {
      await tagRepository.loadBundled();
    }
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      query: query,
      isSearch: true,
      galleries: const [],
      clearNextCursor: true,
    );
    try {
      final result = await _repository.search(
        GallerySearchQuery(
          source: state.source,
          keyword: _translate(query),
        ),
      );
      await ref.read(searchHistoryRepositoryProvider).record(query);
      state = state.copyWith(
        galleries: result.galleries,
        nextCursor: result.nextCursor,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '无法完成搜索。请稍后重试。',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    final cursor = state.nextCursor;
    if (cursor == null) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final result = state.isSearch
          ? await _repository.search(
              GallerySearchQuery(
                source: state.source,
                keyword: _translate(state.query),
                cursor: cursor,
              ),
            )
          : await _repository.discover(source: state.source, cursor: cursor);
      final known = state.galleries.map((gallery) => gallery.key).toSet();
      final appended = [
        ...state.galleries,
        ...result.galleries.where((gallery) => known.add(gallery.key)),
      ];
      state = state.copyWith(
        galleries: appended,
        nextCursor: result.nextCursor,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: '无法加载更多内容。',
      );
    }
  }

  Future<void> switchSource(SiteSource source) async {
    if (state.source == source) {
      return;
    }
    state = DiscoveryState(source: source);
    await load(force: true);
  }
}
