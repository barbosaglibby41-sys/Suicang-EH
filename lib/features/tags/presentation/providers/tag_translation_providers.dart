import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/bundled_tag_translation_repository.dart';
import '../../domain/entities/tag_database_status.dart';
import '../../domain/entities/translated_tag.dart';

final tagTranslationRepositoryProvider =
    ChangeNotifierProvider<BundledTagTranslationRepository>((ref) {
  return BundledTagTranslationRepository();
});

final tagTranslationReadyProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(tagTranslationRepositoryProvider);
  await repository.loadBundled();
  ref.watch(tagTranslationRepositoryProvider);
  return repository.isReady;
});

final tagDatabaseStatusProvider =
    FutureProvider<TagDatabaseStatus>((ref) async {
  final repository = ref.watch(tagTranslationRepositoryProvider);
  return repository.status();
});

final tagSuggestionsProvider =
    Provider.family<List<TranslatedTag>, String>((ref, token) {
  final repository = ref.watch(tagTranslationRepositoryProvider);
  if (!repository.isReady) return const [];
  return repository.suggestions(token);
});
