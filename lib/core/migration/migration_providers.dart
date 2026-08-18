import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import 'migration_importer.dart';

final migrationImporterProvider = Provider<MigrationImporter>((ref) {
  return MigrationImporter(ref.watch(appDatabaseProvider));
});
