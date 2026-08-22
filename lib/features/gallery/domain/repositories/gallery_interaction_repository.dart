import '../entities/gallery.dart';
import '../entities/gallery_comment.dart';
import '../entities/gallery_metadata.dart';

abstract interface class GalleryInteractionRepository {
  Future<List<GalleryComment>> postComment({
    required Gallery gallery,
    required String content,
  });

  Future<GalleryMetadata> rateGallery({
    required Gallery gallery,
    required double rating,
    required GalleryMetadata metadata,
  });

  Future<List<GalleryComment>> voteComment({
    required Gallery gallery,
    required int commentId,
    required bool upvote,
  });
}
