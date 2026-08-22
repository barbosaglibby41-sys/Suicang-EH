import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../../core/network/network_exception.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../authentication/domain/entities/session_validation.dart';
import '../../../gallery/domain/entities/gallery_search_query.dart';
import '../../../gallery/domain/entities/gallery_page_result.dart';
import '../../../gallery/domain/repositories/gallery_repository.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../../tags/presentation/providers/tag_translation_providers.dart';
import '../../../search/presentation/providers/search_history_providers.dart';
import '../../../settings/presentation/providers/site_preferences_providers.dart';
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

  Future<void> initializeSource(SiteSource source) async {
    state = DiscoveryState(source: source);
    await load(force: true);
  }

  Future<void> load({bool force = false}) async {
    if (state.isLoading || (state.galleries.isNotEmpty && !force)) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _discoverWithExRecovery();
      state = state.copyWith(
        galleries: result.galleries,
        nextCursor: result.nextCursor,
        isLoading: false,
        query: '',
        isSearch: false,
        isRandom: false,
        clearError: true,
      );
    } on NetworkException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _discoveryError(error),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '无法加载发现内容。请检查网络和站点会话后重试。',
      );
    }
  }

  String _discoveryError(NetworkException error) {
    if (state.source == SiteSource.exHentai &&
        error.kind == NetworkFailureKind.authenticationRequired) {
      return 'ExHentai 会话无效。请在账户与会话中重新验证或刷新 ExHentai。';
    }
    return switch (error.kind) {
      NetworkFailureKind.timeout => '站点响应超时，请稍后重试。',
      NetworkFailureKind.noConnection => '网络连接失败，请检查网络后重试。',
      NetworkFailureKind.accessDenied =>
        '站点拒绝访问（HTTP ${error.statusCode ?? 403}）。请稍后重试或重新导入 Cookie。',
      NetworkFailureKind.authenticationRequired => '站点需要有效会话，请重新导入 Cookie。',
      NetworkFailureKind.transient =>
        '站点暂时不可用（HTTP ${error.statusCode ?? 500}）。请稍后重试。',
      _ =>
        '无法加载发现内容${error.statusCode == null ? '' : '（HTTP ${error.statusCode}）'}。请检查网络和站点会话后重试。',
    };
  }

  Future<GalleryPageResult> _discoverWithExRecovery() async {
    try {
      return await _repository.discover(source: state.source);
    } on NetworkException catch (error) {
      if (state.source != SiteSource.exHentai ||
          error.kind != NetworkFailureKind.authenticationRequired) {
        rethrow;
      }
      final refreshed =
          await ref.read(sessionServiceProvider).refreshExHentaiSession();
      if (refreshed.status != SessionValidationStatus.valid) rethrow;
      return _repository.discover(source: state.source);
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
        isRandom: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '无法加载热门内容。',
      );
    }
  }

  Future<void> loadRandom({bool fresh = true}) async {
    if (state.isLoading || state.isLoadingMore) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.random(
        source: state.source,
        excluding: fresh
            ? const {}
            : state.galleries.map((gallery) => gallery.key.gid).toSet(),
      );
      state = state.copyWith(
        galleries: fresh ? result : [...state.galleries, ...result],
        clearNextCursor: true,
        isLoading: false,
        query: '',
        isSearch: false,
        isRandom: true,
        randomRound: fresh ? 1 : state.randomRound + 1,
        randomExhausted: result.isEmpty,
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
    if (state.isRandom) {
      await _loadMoreRandom();
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
        clearNextCursor: result.nextCursor == null,
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

  Future<void> _loadMoreRandom() async {
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final fresh = await _repository.random(
        source: state.source,
        excluding: state.galleries.map((gallery) => gallery.key.gid).toSet(),
      );
      final known = state.galleries.map((gallery) => gallery.key).toSet();
      final appended = [
        ...state.galleries,
        ...fresh.where((gallery) => known.add(gallery.key)),
      ];
      state = state.copyWith(
        galleries: appended,
        isLoadingMore: false,
        isRandom: true,
        randomRound: state.randomRound + 1,
        randomExhausted: fresh.isEmpty,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: '无法加载更多随机作品。',
      );
    }
  }

  Future<void> switchSource(SiteSource source) async {
    if (state.source == source) {
      return;
    }
    final current = await ref.read(sitePreferencesProvider.future);
    await ref
        .read(sitePreferencesProvider.notifier)
        .setPreferences(current.copyWith(source: source));
    state = DiscoveryState(source: source);
    await load(force: true);
  }
}
