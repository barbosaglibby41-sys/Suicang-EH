import '../../../gallery/domain/entities/gallery.dart';

class OfflineGallery {
  const OfflineGallery({
    required this.gallery,
    required this.taskId,
    required this.pagePaths,
    required this.totalBytes,
  });

  final Gallery gallery;
  final String taskId;
  final List<String> pagePaths;
  final int totalBytes;

  bool get isReadable => pagePaths.isNotEmpty;
}
