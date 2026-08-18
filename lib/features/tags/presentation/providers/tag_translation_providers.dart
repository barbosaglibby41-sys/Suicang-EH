import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/bundled_tag_translation_repository.dart';
import '../../domain/entities/translated_tag.dart';
import '../../domain/repositories/tag_translation_repository.dart';

final tagTranslationRepositoryProvider =
    Provider<TagTranslationRepository>((ref) {
  return BundledTagTranslationRepository();
});

final tagTranslationReadyProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(tagTranslationRepositoryProvider);
  await repository.loadBundled();
  return repository.isReady;
});

final tagSuggestionsProvider =
    Provider.family<List<TranslatedTag>, String>((ref, token) {
  final repository = ref.watch(tagTranslationRepositoryProvider);
  if (!repository.isReady) return const [];
  return repository.suggestions(token);
});
