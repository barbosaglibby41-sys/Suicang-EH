class SearchHistoryEntry {
  const SearchHistoryEntry({
    required this.id,
    required this.query,
    required this.usedAt,
  });

  final int id;
  final String query;
  final DateTime usedAt;
}
