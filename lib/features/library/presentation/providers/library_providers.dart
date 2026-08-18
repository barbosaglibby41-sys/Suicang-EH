import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/drift_library_repository.dart';
import '../../domain/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return DriftLibraryRepository(ref.watch(appDatabaseProvider));
});

final favoriteGalleriesProvider = StreamProvider((ref) {
  return ref.watch(libraryRepositoryProvider).watchFavorites();
});

final historyGalleriesProvider = StreamProvider((ref) {
  return ref.watch(libraryRepositoryProvider).watchHistory();
});
