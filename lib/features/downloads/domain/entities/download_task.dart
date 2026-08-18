import '../../../gallery/domain/entities/gallery_key.dart';

enum DownloadStatus { queued, downloading, paused, completed, failed, cancelled }

class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.galleryKey,
    required this.totalPages,
    required this.completedPages,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.failureCode,
  })  : assert(totalPages >= 0),
        assert(completedPages >= 0),
        assert(completedPages <= totalPages || totalPages == 0);

  final String id;
  final GalleryKey galleryKey;
  final int totalPages;
  final int completedPages;
  final DownloadStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? failureCode;

  double get progress => totalPages == 0 ? 0 : completedPages / totalPages;
}
