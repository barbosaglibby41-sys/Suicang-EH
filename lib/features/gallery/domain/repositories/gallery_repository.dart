import '../entities/gallery.dart';
import '../entities/gallery_detail.dart';
import '../entities/gallery_key.dart';
import '../entities/gallery_page_result.dart';
import '../entities/gallery_search_query.dart';
import '../../../rankings/domain/entities/ranking_period.dart';
import '../../../rankings/domain/entities/ranking_page.dart';

abstract interface class GalleryRepository {
  Future<GalleryPageResult> discover({
    required SiteSource source,
    int? cursor,
  });
  Future<GalleryPageResult> search(GallerySearchQuery query);
  Future<GalleryPageResult> popular({required SiteSource source});
  Future<RankingPage> rankings({
    required SiteSource source,
    required RankingPeriod period,
    int page = 0,
  });
  Future<List<Gallery>> random({
    required SiteSource source,
    int count = 12,
    Set<int> excluding = const {},
  });
  Future<GalleryDetail> loadDetail(Gallery gallery, {bool includePageLinks = false});
  Future<Uri> resolveImageUrl(Uri pageUrl, {Uri? referer, bool forceRefresh = false});
  Future<Uri?> torrentUrl(Gallery gallery);

  Future<Gallery?> findByKey(GalleryKey key);
  Future<void> upsert(Gallery gallery);
}
