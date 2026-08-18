import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/drift_offline_library_repository.dart';
import '../../domain/entities/offline_gallery.dart';
import '../../domain/repositories/offline_library_repository.dart';

final offlineLibraryRepositoryProvider = Provider<OfflineLibraryRepository>((ref) {
  return DriftOfflineLibraryRepository(ref.watch(appDatabaseProvider));
});

final offlineLibraryProvider = StreamProvider<List<OfflineGallery>>((ref) {
  return ref.watch(offlineLibraryRepositoryProvider).watchCompleted();
});
