import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/network/network_providers.dart';
import '../../../settings/presentation/providers/site_preferences_providers.dart';
import '../../data/repositories/eh_gallery_repository.dart';
import '../../domain/repositories/gallery_repository.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final preferences = ref.watch(sitePreferencesProvider).valueOrNull;
  return EhGalleryRepository(
    database: ref.watch(appDatabaseProvider),
    client: ref.watch(siteHttpClientProvider),
    preferPublicDetailRedirect:
        preferences?.preferPublicDetailRedirect ?? true,
  );
});
