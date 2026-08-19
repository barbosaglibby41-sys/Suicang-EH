import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';

class DiscoveryState {
  const DiscoveryState({
    required this.source,
    this.galleries = const [],
    this.nextCursor,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.query = '',
    this.isSearch = false,
    this.isRandom = false,
  });

  final SiteSource source;
  final List<Gallery> galleries;
  final int? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String query;
  final bool isSearch;
  final bool isRandom;

  bool get hasMore => isRandom || nextCursor != null;

  bool get isEmpty => galleries.isEmpty && !isLoading;

  DiscoveryState copyWith({
    SiteSource? source,
    List<Gallery>? galleries,
    int? nextCursor,
    bool clearNextCursor = false,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    String? query,
    bool? isSearch,
    bool? isRandom,
  }) {
    return DiscoveryState(
      source: source ?? this.source,
      galleries: galleries ?? this.galleries,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      isSearch: isSearch ?? this.isSearch,
      isRandom: isRandom ?? this.isRandom,
    );
  }
}
