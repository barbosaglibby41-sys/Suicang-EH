import '../entities/gallery.dart';
import '../entities/gallery_key.dart';

abstract interface class GalleryRepository {
  Future<Gallery?> findByKey(GalleryKey key);

  Future<void> upsert(Gallery gallery);
}
