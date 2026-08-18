import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/repositories/eh_gallery_repository.dart';
import '../../domain/repositories/gallery_repository.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return EhGalleryRepository(
    database: ref.watch(appDatabaseProvider),
    client: ref.watch(siteHttpClientProvider),
  );
});
