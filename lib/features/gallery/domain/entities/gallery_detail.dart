import 'gallery.dart';
import 'gallery_comment.dart';
import 'gallery_metadata.dart';
import 'page_preview.dart';

class GalleryDetail {
  const GalleryDetail({
    required this.gallery,
    required this.pageLinks,
    this.metadata = const GalleryMetadata(),
    this.comments = const [],
    this.previews = const [],
  });

  final Gallery gallery;
  final List<Uri> pageLinks;
  final GalleryMetadata metadata;
  final List<GalleryComment> comments;
  final List<PagePreview> previews;
}
