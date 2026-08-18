import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../../settings/presentation/providers/site_preferences_providers.dart';
import '../../domain/entities/ranking_period.dart';

final rankingsNotifierProvider =
    NotifierProvider<RankingsNotifier, RankingsState>(RankingsNotifier.new);

class RankingsState {
  const RankingsState({
    this.source = SiteSource.eHentai,
    this.byPeriod = const {},
    this.nextPages = const {},
    this.isLoading = false,
    this.loadingMore = const {},
    this.errorMessage,
  });

  final SiteSource source;
  final Map<RankingPeriod, List<Gallery>> byPeriod;
  final Map<RankingPeriod, int?> nextPages;
  final bool isLoading;
  final Set<RankingPeriod> loadingMore;
  final String? errorMessage;

  List<Gallery> galleries(RankingPeriod period) => byPeriod[period] ?? const [];
  bool canLoadMore(RankingPeriod period) => nextPages[period] != null;

  RankingsState copyWith({
    SiteSource? source,
    Map<RankingPeriod, List<Gallery>>? byPeriod,
    Map<RankingPeriod, int?>? nextPages,
    bool? isLoading,
    Set<RankingPeriod>? loadingMore,
    String? errorMessage,
    bool clearError = false,
  }) => RankingsState(
        source: source ?? this.source,
        byPeriod: byPeriod ?? this.byPeriod,
        nextPages: nextPages ?? this.nextPages,
        isLoading: isLoading ?? this.isLoading,
        loadingMore: loadingMore ?? this.loadingMore,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

class RankingsNotifier extends Notifier<RankingsState> {
  @override
  RankingsState build() => const RankingsState();

  Future<void> initialize(RankingPeriod period) async {
    final preferences = await ref.read(sitePreferencesProvider.future);
    state = RankingsState(source: preferences.source);
    await load(period, force: true);
  }

  Future<void> load(RankingPeriod period, {bool force = false}) async {
    if (state.isLoading || (!force && state.galleries(period).isNotEmpty)) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await ref.read(galleryRepositoryProvider).rankings(
            source: state.source,
            period: period,
          );
      state = state.copyWith(
        byPeriod: {...state.byPeriod, period: page.galleries},
        nextPages: {...state.nextPages, period: page.nextPage},
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '${period.label}排行加载失败。',
      );
    }
  }

  Future<void> loadMore(RankingPeriod period) async {
    final next = state.nextPages[period];
    if (next == null || state.loadingMore.contains(period)) return;
    state = state.copyWith(
      loadingMore: {...state.loadingMore, period},
      clearError: true,
    );
    try {
      final page = await ref.read(galleryRepositoryProvider).rankings(
            source: state.source,
            period: period,
            page: next,
          );
      final known = state.galleries(period).map((gallery) => gallery.key).toSet();
      final combined = [
        ...state.galleries(period),
        ...page.galleries.where((gallery) => known.add(gallery.key)),
      ];
      final loading = {...state.loadingMore}..remove(period);
      state = state.copyWith(
        byPeriod: {...state.byPeriod, period: combined},
        nextPages: {...state.nextPages, period: page.nextPage},
        loadingMore: loading,
        clearError: true,
      );
    } catch (_) {
      final loading = {...state.loadingMore}..remove(period);
      state = state.copyWith(
        loadingMore: loading,
        errorMessage: '${period.label}排行加载失败。',
      );
    }
  }
}
