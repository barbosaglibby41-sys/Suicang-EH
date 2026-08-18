import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/drift_subscribed_tags_repository.dart';
import '../../domain/repositories/subscribed_tags_repository.dart';

final subscribedTagsRepositoryProvider = Provider<SubscribedTagsRepository>((ref) {
  return DriftSubscribedTagsRepository(ref.watch(appDatabaseProvider));
});

final subscribedTagsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(subscribedTagsRepositoryProvider).watchAll();
});
