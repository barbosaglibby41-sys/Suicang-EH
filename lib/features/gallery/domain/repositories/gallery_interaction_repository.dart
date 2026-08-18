import '../entities/gallery.dart';
import '../entities/gallery_comment.dart';

abstract interface class GalleryInteractionRepository {
  Future<List<GalleryComment>> postComment({
    required Gallery gallery,
    required String content,
  });
}
