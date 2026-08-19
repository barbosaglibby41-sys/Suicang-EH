import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../gallery/presentation/providers/gallery_providers.dart';
import '../../data/repositories/drift_followed_creator_repository.dart';
import '../../domain/entities/followed_creator.dart';
import '../../domain/repositories/followed_creator_repository.dart';

final followedCreatorRepositoryProvider =
    Provider<FollowedCreatorRepository>((ref) {
  return DriftFollowedCreatorRepository(
    database: ref.watch(appDatabaseProvider),
    galleryRepository: ref.watch(galleryRepositoryProvider),
  );
});

final followedCreatorsProvider = StreamProvider<List<FollowedCreator>>((ref) {
  return ref.watch(followedCreatorRepositoryProvider).watchAll();
});
