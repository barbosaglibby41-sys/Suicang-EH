import 'dart:io';

import '../../domain/entities/reader_models.dart';
import '../../domain/page_source/page_source.dart';

class OfflinePageSource implements PageSource {
  OfflinePageSource(this._files);

  final List<File> _files;

  @override
  Future<int> pageCount() async => _files.length;

  @override
  Future<ReaderPage> pageAt(int index) async {
    _check(index);
    return ReaderPage(index: index, source: Uri.file(_files[index].path));
  }

  @override
  Future<void> invalidate(int index) async {
    // Local files are authoritative; there is no network URL to refresh.
  }

  void _check(int index) {
    if (index < 0 || index >= _files.length) {
      throw RangeError.index(index, _files, 'index');
    }
  }
}
