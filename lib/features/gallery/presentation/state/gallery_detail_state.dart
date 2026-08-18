import '../../domain/entities/gallery.dart';

class GalleryDetailState {
  const GalleryDetailState({
    required this.gallery,
    this.isLoading = false,
    this.errorMessage,
  });

  final Gallery gallery;
  final bool isLoading;
  final String? errorMessage;

  GalleryDetailState copyWith({
    Gallery? gallery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GalleryDetailState(
      gallery: gallery ?? this.gallery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
