import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_comment.dart';
import '../../domain/entities/gallery_metadata.dart';
import '../../domain/entities/page_preview.dart';

class GalleryDetailState {
  const GalleryDetailState({
    required this.gallery,
    this.metadata = const GalleryMetadata(),
    this.comments = const [],
    this.previews = const [],
    this.isLoading = false,
    this.isLoadingPreviews = false,
    this.errorMessage,
  });

  final Gallery gallery;
  final GalleryMetadata metadata;
  final List<GalleryComment> comments;
  final List<PagePreview> previews;
  final bool isLoading;
  final bool isLoadingPreviews;
  final String? errorMessage;

  GalleryDetailState copyWith({
    Gallery? gallery,
    GalleryMetadata? metadata,
    List<GalleryComment>? comments,
    List<PagePreview>? previews,
    bool? isLoading,
    bool? isLoadingPreviews,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GalleryDetailState(
      gallery: gallery ?? this.gallery,
      metadata: metadata ?? this.metadata,
      comments: comments ?? this.comments,
      previews: previews ?? this.previews,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPreviews: isLoadingPreviews ?? this.isLoadingPreviews,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
