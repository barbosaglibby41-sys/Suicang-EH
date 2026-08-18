import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/repositories/eh_gallery_interaction_repository.dart';
import '../../domain/repositories/gallery_interaction_repository.dart';

final galleryInteractionRepositoryProvider =
    Provider<GalleryInteractionRepository>((ref) {
  return EhGalleryInteractionRepository(
    client: ref.watch(siteHttpClientProvider),
  );
});
