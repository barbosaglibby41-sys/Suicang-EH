import '../entities/gallery.dart';
import '../entities/gallery_detail.dart';
import '../entities/gallery_key.dart';
import '../entities/gallery_page_result.dart';
import '../entities/gallery_search_query.dart';

abstract interface class GalleryRepository {
  Future<GalleryPageResult> discover({
    required SiteSource source,
    int? cursor,
  });
  Future<GalleryPageResult> search(GallerySearchQuery query);
  Future<GalleryDetail> loadDetail(Gallery gallery, {bool includePageLinks = false});
  Future<Uri> resolveImageUrl(Uri pageUrl, {Uri? referer, bool forceRefresh = false});

  Future<Gallery?> findByKey(GalleryKey key);
  Future<void> upsert(Gallery gallery);
}
