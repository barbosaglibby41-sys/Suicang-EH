import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/repositories/gallery_repository.dart';
import '../../domain/entities/reader_models.dart';
import '../../domain/page_source/page_source.dart';

class OnlinePageSource implements PageSource {
  OnlinePageSource({
    required Gallery gallery,
    required GalleryRepository repository,
  })  : _gallery = gallery,
        _repository = repository;

  final Gallery _gallery;
  final GalleryRepository _repository;
  List<Uri>? _pageLinks;
  final _resolved = <int, Uri>{};

  @override
  Future<int> pageCount() async {
    final links = await _manifest();
    return links.length;
  }

  @override
  Future<ReaderPage> pageAt(int index) async {
    final links = await _manifest();
    if (index < 0 || index >= links.length) {
      throw RangeError.index(index, links, 'index');
    }
    final image = _resolved[index] ??= await _repository.resolveImageUrl(
      links[index],
      referer: _gallery.sourceUrl,
    );
    return ReaderPage(index: index, source: image);
  }

  @override
  Future<void> invalidate(int index) async {
    _resolved.remove(index);
    final links = await _manifest();
    if (index < 0 || index >= links.length) return;
    _resolved[index] = await _repository.resolveImageUrl(
      links[index],
      referer: _gallery.sourceUrl,
      forceRefresh: true,
    );
  }

  Future<List<Uri>> _manifest() async {
    final cached = _pageLinks;
    if (cached != null) return cached;
    final detail = await _repository.loadDetail(
      _gallery,
      includePageLinks: true,
    );
    return _pageLinks = detail.pageLinks;
  }
}
