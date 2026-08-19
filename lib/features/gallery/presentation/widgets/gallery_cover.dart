import 'package:flutter/material.dart';

import '../../../../core/image/image_request.dart';
import '../../../../core/image/pipeline_image.dart';
import '../../domain/entities/gallery.dart';
import 'gallery_cover_placeholder.dart';

class GalleryCover extends StatelessWidget {
  const GalleryCover({
    required this.gallery,
    this.variant = ImageVariant.cover,
    this.targetPixels = 720,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    super.key,
  });

  final Gallery gallery;
  final ImageVariant variant;
  final int targetPixels;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final thumbnail = gallery.thumbnailUrl;
    if (thumbnail == null) {
      return GalleryCoverPlaceholder(gallery: gallery);
    }
    return Semantics(
      image: true,
      label: '作品封面：${gallery.title}',
      child: PipelineImage(
        url: thumbnail,
        source: gallery.key.source,
        variant: variant,
        targetPixels: targetPixels,
        fit: BoxFit.cover,
        borderRadius: borderRadius,
      ),
    );
  }
}
