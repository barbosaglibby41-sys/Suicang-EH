import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/reader_models.dart';
import '../../domain/entities/reader_preferences.dart';
import '../../domain/repositories/reader_preferences_repository.dart';

class SharedPreferencesReaderPreferencesRepository
    implements ReaderPreferencesRepository {
  static const _modeKey = 'taro.eh.reader.mode';
  static const _directionKey = 'taro.eh.reader.direction';
  static const _fitKey = 'taro.eh.reader.fit';
  static const _keepScreenOnKey = 'taro.eh.reader.keep_screen_on';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<ReaderPreferences> load() async {
    final preferences = await _preferences;
    return ReaderPreferences(
      mode: _enumOr(ReaderMode.values, preferences.getString(_modeKey),
          ReaderMode.horizontal),
      direction: _enumOr(
        ReaderDirection.values,
        preferences.getString(_directionKey),
        ReaderDirection.ltr,
      ),
      fit: _enumOr(
          ReaderFit.values, preferences.getString(_fitKey), ReaderFit.contain),
      keepScreenOn: preferences.getBool(_keepScreenOnKey) ?? true,
    );
  }

  @override
  Future<void> save(ReaderPreferences value) async {
    final preferences = await _preferences;
    await Future.wait([
      preferences.setString(_modeKey, value.mode.name),
      preferences.setString(_directionKey, value.direction.name),
      preferences.setString(_fitKey, value.fit.name),
      preferences.setBool(_keepScreenOnKey, value.keepScreenOn),
    ]);
  }

  T _enumOr<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
