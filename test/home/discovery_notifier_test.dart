import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_detail.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_key.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_page_result.dart';
import 'package:taro_eh_flutter/features/gallery/domain/entities/gallery_search_query.dart';
import 'package:taro_eh_flutter/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:taro_eh_flutter/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:taro_eh_flutter/features/rankings/domain/entities/ranking_period.dart';
import 'package:taro_eh_flutter/features/home/presentation/notifiers/discovery_notifier.dart';

void main() {
  test('deduplicates galleries when loading subsequent pages', () async {
    final repository = _FakeGalleryRepository([
      GalleryPageResult(
        galleries: const [
          Gallery(
            key: GalleryKey(source: SiteSource.eHentai, gid: 1),
            title: 'First',
            pageCount: 3,
          ),
        ],
        nextCursor: 2,
      ),
      GalleryPageResult(
        galleries: const [
          Gallery(
            key: GalleryKey(source: SiteSource.eHentai, gid: 1),
            title: 'First duplicate',
            pageCount: 3,
          ),
          Gallery(
            key: GalleryKey(source: SiteSource.eHentai, gid: 2),
            title: 'Second',
            pageCount: 4,
          ),
        ],
      ),
    ]);
    final container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(discoveryNotifierProvider.notifier);
    await notifier.load();
    await notifier.loadMore();

    final state = container.read(discoveryNotifierProvider);
    expect(state.galleries.map((gallery) => gallery.key.gid), [1, 2]);
    expect(state.hasMore, isFalse);
  });
}

class _FakeGalleryRepository implements GalleryRepository {
  _FakeGalleryRepository(this.pages);

  final List<GalleryPageResult> pages;
  var _index = 0;

  @override
  Future<GalleryPageResult> discover({
    required SiteSource source,
    int? cursor,
  }) async => pages[_index++];

  @override
  Future<Gallery?> findByKey(GalleryKey key) async => null;

  @override
  Future<GalleryDetail> loadDetail(
    Gallery gallery, {
    bool includePageLinks = false,
  }) async => GalleryDetail(gallery: gallery, pageLinks: const []);

  @override
  Future<Uri> resolveImageUrl(
    Uri pageUrl, {
    Uri? referer,
    bool forceRefresh = false,
  }) async => pageUrl;

  @override
  Future<GalleryPageResult> search(GallerySearchQuery query) async => pages[_index++];

  @override
  Future<GalleryPageResult> popular({required SiteSource source}) async => pages[_index++];

  @override
  Future<GalleryPageResult> rankings({
    required SiteSource source,
    required RankingPeriod period,
    int page = 0,
  }) async => pages[_index++];

  @override
  Future<List<Gallery>> random({
    required SiteSource source,
    int count = 12,
    Set<int> excluding = const {},
  }) async => const [];

  @override
  Future<Uri?> torrentUrl(Gallery gallery) async => null;

  @override
  Future<void> upsert(Gallery gallery) async {}
}
