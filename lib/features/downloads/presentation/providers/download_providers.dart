import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/network/network_providers.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../data/datasources/download_file_store.dart';
import '../../data/repositories/drift_download_repository.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/repositories/download_repository.dart';

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  final repository = DriftDownloadRepository(
    database: ref.watch(appDatabaseProvider),
    client: ref.watch(siteHttpClientProvider),
    fileStore: DownloadFileStore(),
    galleryRepository: ref.watch(galleryRepositoryProvider),
  );
  unawaited(repository.recoverInterrupted());
  return repository;
});

final downloadTasksProvider = StreamProvider<List<DownloadTask>>((ref) {
  return ref.watch(downloadRepositoryProvider).watchAll();
});
