import '../entities/offline_gallery.dart';

abstract interface class OfflineLibraryRepository {
  Stream<List<OfflineGallery>> watchCompleted();
  Future<void> delete(OfflineGallery gallery);
}
