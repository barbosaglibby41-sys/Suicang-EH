import '../entities/reading_progress.dart';
import '../../../gallery/domain/entities/gallery_key.dart';

abstract interface class ReadingProgressRepository {
  Stream<ReadingProgress?> watch(GalleryKey key);
  Future<ReadingProgress?> get(GalleryKey key);
  Future<void> save(ReadingProgress progress);
  Future<void> clear(GalleryKey key);
}
