import '../entities/reader_preferences.dart';

abstract interface class ReaderPreferencesRepository {
  Future<ReaderPreferences> load();
  Future<void> save(ReaderPreferences preferences);
}
