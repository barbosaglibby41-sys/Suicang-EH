import '../entities/search_history_entry.dart';

abstract interface class SearchHistoryRepository {
  Stream<List<SearchHistoryEntry>> watchRecent({int limit = 12});
  Future<void> record(String query);
  Future<void> remove(int id);
  Future<void> clear();
}
