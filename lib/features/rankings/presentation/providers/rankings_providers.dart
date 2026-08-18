import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../domain/entities/ranking_period.dart';

final rankingsNotifierProvider =
    NotifierProvider<RankingsNotifier, RankingsState>(RankingsNotifier.new);

class RankingsState {
  const RankingsState({
    this.source = SiteSource.eHentai,
    this.byPeriod = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  final SiteSource source;
  final Map<RankingPeriod, List<Gallery>> byPeriod;
  final bool isLoading;
  final String? errorMessage;

  List<Gallery> galleries(RankingPeriod period) => byPeriod[period] ?? const [];

  RankingsState copyWith({
    SiteSource? source,
    Map<RankingPeriod, List<Gallery>>? byPeriod,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => RankingsState(
        source: source ?? this.source,
        byPeriod: byPeriod ?? this.byPeriod,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

class RankingsNotifier extends Notifier<RankingsState> {
  @override
  RankingsState build() => const RankingsState();

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
}
