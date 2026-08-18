import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/shared_preferences_reader_preferences_repository.dart';
import '../../domain/entities/reader_preferences.dart';
import '../../domain/repositories/reader_preferences_repository.dart';

final readerPreferencesRepositoryProvider = Provider<ReaderPreferencesRepository>((ref) {
  return SharedPreferencesReaderPreferencesRepository();
});

final readerPreferencesProvider =
    AsyncNotifierProvider<ReaderPreferencesNotifier, ReaderPreferences>(
  ReaderPreferencesNotifier.new,
);

class ReaderPreferencesNotifier extends AsyncNotifier<ReaderPreferences> {
  ReaderPreferencesRepository get _repository =>
      ref.read(readerPreferencesRepositoryProvider);

  @override
  Future<ReaderPreferences> build() => _repository.load();

  Future<void> update(ReaderPreferences preferences) async {
    state = AsyncData(preferences);
    await _repository.save(preferences);
  }
}
