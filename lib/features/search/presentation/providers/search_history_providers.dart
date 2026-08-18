import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/drift_search_history_repository.dart';
import '../../domain/entities/search_history_entry.dart';
import '../../domain/repositories/search_history_repository.dart';

final searchHistoryRepositoryProvider =
    Provider<SearchHistoryRepository>((ref) {
  return DriftSearchHistoryRepository(ref.watch(appDatabaseProvider));
});

final searchHistoryProvider = StreamProvider<List<SearchHistoryEntry>>((ref) {
  return ref.watch(searchHistoryRepositoryProvider).watchRecent();
});
