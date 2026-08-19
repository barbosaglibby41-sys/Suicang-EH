import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../entities/library_filter.dart';

abstract interface class LibraryRepository {
  Stream<List<Gallery>> watchFavorites({LibraryFilter filter = const LibraryFilter()});
  Stream<List<Gallery>> watchHistory({int limit = 100, LibraryFilter filter = const LibraryFilter()});

  Future<bool> isFavorite(GalleryKey key);
  Future<void> setFavorite(Gallery gallery, {required bool value});
  Future<void> recordOpened(Gallery gallery, {DateTime? openedAt});
  Future<void> clearHistory();
}
