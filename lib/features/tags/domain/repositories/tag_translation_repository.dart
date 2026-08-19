import '../entities/tag_database_status.dart';
import '../entities/translated_tag.dart';

abstract interface class TagTranslationRepository {
  Future<void> loadBundled();
  Future<TagDatabaseStatus> status();
  Future<TagDatabaseStatus> updateFromRemote();
  Future<void> restoreBundled();
  bool get isReady;
  TranslatedTag? find(String value);
  List<TranslatedTag> suggestions(String token, {int limit = 12});
  String translateQuery(String query);
}
