import '../entities/translated_tag.dart';

abstract interface class TagTranslationRepository {
  Future<void> loadBundled();
  bool get isReady;
  TranslatedTag? find(String value);
  List<TranslatedTag> suggestions(String token, {int limit = 12});
  String translateQuery(String query);
}
