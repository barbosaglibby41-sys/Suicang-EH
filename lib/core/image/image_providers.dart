import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_providers.dart';
import 'image_pipeline.dart';

final imagePipelineProvider = Provider<ImagePipeline>((ref) {
  return ImagePipeline(client: ref.watch(siteHttpClientProvider));
});
