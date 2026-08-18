import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/shared_preferences_site_preferences_repository.dart';
import '../../domain/entities/site_preferences.dart';
import '../../domain/repositories/site_preferences_repository.dart';

final sitePreferencesRepositoryProvider =
    Provider<SitePreferencesRepository>((ref) {
  return SharedPreferencesSitePreferencesRepository();
});

final sitePreferencesProvider =
    AsyncNotifierProvider<SitePreferencesNotifier, SitePreferences>(
  SitePreferencesNotifier.new,
);

class SitePreferencesNotifier extends AsyncNotifier<SitePreferences> {
  SitePreferencesRepository get _repository =>
      ref.read(sitePreferencesRepositoryProvider);

  @override
  Future<SitePreferences> build() => _repository.load();

  Future<void> update(SitePreferences preferences) async {
    state = AsyncData(preferences);
    await _repository.save(preferences);
  }
}
