import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/drift_library_repository.dart';
import '../../domain/entities/library_filter.dart';
import '../../domain/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return DriftLibraryRepository(ref.watch(appDatabaseProvider));
});

final favoriteGalleriesProvider =
    StreamProvider.family((ref, LibraryFilter filter) {
  return ref.watch(libraryRepositoryProvider).watchFavorites(filter: filter);
});

final historyGalleriesProvider =
    StreamProvider.family((ref, LibraryFilter filter) {
  return ref.watch(libraryRepositoryProvider).watchHistory(filter: filter);
});
