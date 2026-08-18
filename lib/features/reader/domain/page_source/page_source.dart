import '../entities/reader_models.dart';

abstract interface class PageSource {
  Future<int> pageCount();
  Future<ReaderPage> pageAt(int index);
  Future<void> invalidate(int index);
}
