import '../../../gallery/domain/entities/gallery.dart';

class DownloadRequest {
  const DownloadRequest({
    required this.gallery,
    required this.pageUrls,
  });

  final Gallery gallery;
  final List<Uri> pageUrls;
}
