import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/drift_reading_progress_repository.dart';
import '../../domain/repositories/reading_progress_repository.dart';

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>((ref) {
  return DriftReadingProgressRepository(ref.watch(appDatabaseProvider));
});
