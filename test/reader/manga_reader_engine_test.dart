import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/features/gallery/domain/entities/gallery_key.dart';
import 'package:suicang_eh/features/reader/domain/engine/manga_reader_engine.dart';
import 'package:suicang_eh/features/reader/domain/entities/reader_models.dart';
import 'package:suicang_eh/features/reader/domain/page_source/page_source.dart';

void main() {
  test('clamps navigation and schedules adjacent pages', () async {
    final source = _FakePageSource(5);
    final preloaded = <int>[];
    final engine = MangaReaderEngine(
      pageSource: source,
      initialState: const ReaderState(
        galleryKey: GalleryKey(source: SiteSource.eHentai, gid: 1),
        mode: ReaderMode.horizontal,
        direction: ReaderDirection.ltr,
        fit: ReaderFit.contain,
        pageCount: 0,
        currentIndex: 0,
      ),
    );
    engine.preloadRequests.listen(preloaded.add);

    await engine.initialize();
    await engine.goTo(99);

    expect(engine.state.pageCount, 5);
    expect(engine.state.currentIndex, 4);
    expect(preloaded, containsAll(<int>[1, 2]));
    await engine.dispose();
  });

  test('invalidates the current online page before retrying', () async {
    final source = _FakePageSource(2);
    final engine = MangaReaderEngine(
      pageSource: source,
      initialState: const ReaderState(
        galleryKey: GalleryKey(source: SiteSource.eHentai, gid: 2),
        mode: ReaderMode.horizontal,
        direction: ReaderDirection.ltr,
        fit: ReaderFit.contain,
        pageCount: 0,
        currentIndex: 0,
      ),
    );

    await engine.initialize();
    await engine.retryCurrentPage();

    expect(source.invalidated, [0]);
    await engine.dispose();
  });
}

class _FakePageSource implements PageSource {
  _FakePageSource(this.count);

  final int count;
  final invalidated = <int>[];

  @override
  Future<void> invalidate(int index) async => invalidated.add(index);

  @override
  Future<ReaderPage> pageAt(int index) async =>
      ReaderPage(index: index, source: Uri.parse('file:///page-$index.jpg'));

  @override
  Future<int> pageCount() async => count;
}
