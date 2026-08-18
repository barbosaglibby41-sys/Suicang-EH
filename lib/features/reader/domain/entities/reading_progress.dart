import '../../../gallery/domain/entities/gallery_key.dart';

class ReadingProgress {
  const ReadingProgress({
    required this.galleryKey,
    required this.pageIndex,
    required this.pageCount,
    required this.updatedAt,
  })  : assert(pageIndex >= 0, 'pageIndex cannot be negative'),
        assert(pageCount >= 0, 'pageCount cannot be negative');

  final GalleryKey galleryKey;
  final int pageIndex;
  final int pageCount;
  final DateTime updatedAt;
}
