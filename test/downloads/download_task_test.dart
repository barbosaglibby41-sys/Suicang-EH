import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/downloads/domain/entities/download_task.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';

void main() {
  test('calculates task progress without dividing by zero', () {
    final now = DateTime.utc(2026, 8, 19);
    final empty = DownloadTask(
      id: 'empty',
      galleryKey: const GalleryKey(source: SiteSource.eHentai, gid: 1),
      totalPages: 0,
      completedPages: 0,
      status: DownloadStatus.queued,
      createdAt: now,
      updatedAt: now,
    );
    final partial = DownloadTask(
      id: 'partial',
      galleryKey: const GalleryKey(source: SiteSource.eHentai, gid: 2),
      totalPages: 4,
      completedPages: 1,
      status: DownloadStatus.downloading,
      createdAt: now,
      updatedAt: now,
    );

    expect(empty.progress, 0);
    expect(partial.progress, 0.25);
  });
}
