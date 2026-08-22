import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/image/image_providers.dart';
import '../../../../core/image/image_request.dart';
import '../../domain/entities/gallery_key.dart';
import '../../domain/entities/page_preview.dart';

class PreviewStrip extends ConsumerWidget {
  const PreviewStrip({
    required this.previews,
    required this.source,
    this.onSelectPage,
    super.key,
  });

  final List<PagePreview> previews;
  final SiteSource source;
  final ValueChanged<PagePreview>? onSelectPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (previews.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      itemCount: previews.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) => _PreviewTile(
        preview: previews[index],
        source: source,
        onTap:
            onSelectPage == null ? null : () => onSelectPage!(previews[index]),
      ),
    );
  }
}

class _PreviewTile extends ConsumerWidget {
  const _PreviewTile({
    required this.preview,
    required this.source,
    this.onTap,
  });

  final PagePreview preview;
  final SiteSource source;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.read(imagePipelineProvider).load(
          ImageRequest(
            url: preview.spriteUrl,
            referer: preview.referer,
            variant: ImageVariant.thumbnail,
            targetPixels: 1600,
          ),
          source: source,
        );
    return SizedBox(
      width: 104,
      child: FutureBuilder<Uint8List>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Icon(Icons.broken_image_outlined);
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return FutureBuilder<ui.Codec>(
            future: ui.instantiateImageCodec(snapshot.data!),
            builder: (context, codecSnapshot) {
              if (!codecSnapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              return FutureBuilder<ui.FrameInfo>(
                future: codecSnapshot.data!.getNextFrame(),
                builder: (context, frameSnapshot) {
                  if (!frameSnapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final image = frameSnapshot.data!.image;
                  return Semantics(
                    button: onTap != null,
                    label: '预览第 ${preview.page} 页',
                    hint: onTap == null ? null : '从此页开始阅读',
                    child: GestureDetector(
                      onTap: onTap,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomPaint(
                          size: const Size(104, 140),
                          painter:
                              _SpritePainter(image: image, preview: preview),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              color: Colors.black.withValues(alpha: 0.7),
                              child: Text(
                                '${preview.page}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  const _SpritePainter({required this.image, required this.preview});

  final ui.Image image;
  final PagePreview preview;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Rect.fromLTWH(
      preview.xOffset.toDouble(),
      preview.yOffset.toDouble(),
      preview.width.toDouble(),
      preview.height.toDouble(),
    );
    final scale = size.width / preview.width;
    final targetHeight = preview.height * scale;
    final destination = Rect.fromLTWH(0, 0, size.width, targetHeight);
    canvas.drawImageRect(image, source, destination, Paint());
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.preview != preview;
}
