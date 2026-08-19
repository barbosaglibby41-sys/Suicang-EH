import '../entities/gallery.dart';
import '../entities/gallery_comment.dart';

abstract interface class GalleryInteractionRepository {
  Future<List<GalleryComment>> postComment({
    required Gallery gallery,
    required String content,
  });

  Future<List<GalleryComment>> voteComment({
    required Gallery gallery,
    required int commentId,
    required bool upvote,
  });
}
