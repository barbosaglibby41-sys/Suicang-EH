import '../entities/gallery.dart';
import '../entities/gallery_key.dart';

abstract interface class LibraryRepository {
  Stream<List<Gallery>> watchFavorites();
  Stream<List<Gallery>> watchHistory({int limit = 100});

  Future<bool> isFavorite(GalleryKey key);
  Future<void> setFavorite(Gallery gallery, {required bool value});
  Future<void> recordOpened(Gallery gallery, {DateTime? openedAt});
  Future<void> clearHistory();
}
