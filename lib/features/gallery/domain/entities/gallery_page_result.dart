import 'gallery.dart';

class GalleryPageResult {
  const GalleryPageResult({
    required this.galleries,
    this.nextCursor,
  });

  final List<Gallery> galleries;
  final int? nextCursor;

  bool get hasMore => nextCursor != null;
}
