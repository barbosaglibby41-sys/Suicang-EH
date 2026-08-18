import 'gallery.dart';

class GalleryDetail {
  const GalleryDetail({
    required this.gallery,
    required this.pageLinks,
  });

  final Gallery gallery;
  final List<Uri> pageLinks;
}
