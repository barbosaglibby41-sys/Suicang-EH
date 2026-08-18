import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/gallery/domain/entities/gallery_key.dart';
import 'image_pipeline.dart';
import 'image_providers.dart';
import 'image_request.dart';

class PipelineImage extends ConsumerStatefulWidget {
  const PipelineImage({
    required this.url,
    required this.source,
    this.referer,
    this.variant = ImageVariant.cover,
    this.targetPixels = 720,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  });

  final Uri url;
  final SiteSource source;
  final Uri? referer;
  final ImageVariant variant;
  final int targetPixels;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  ConsumerState<PipelineImage> createState() => _PipelineImageState();
}

class _PipelineImageState extends ConsumerState<PipelineImage> {
  Uint8List? _bytes;
  Object? _error;
  CancelHandle? _cancel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PipelineImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.variant != widget.variant ||
        oldWidget.targetPixels != widget.targetPixels) {
      _cancel?.cancel();
      _bytes = null;
      _error = null;
      _load();
    }
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.zero;
    return ClipRRect(
      borderRadius: radius,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: _bytes != null
            ? Image.memory(
                _bytes!,
                key: const ValueKey('loaded'),
                fit: widget.fit,
                width: double.infinity,
                height: double.infinity,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              )
            : _error != null
                ? const ColoredBox(
                    key: ValueKey('error'),
                    color: Color(0xFFE8E5ED),
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  )
                : const ColoredBox(
                    key: ValueKey('loading'),
                    color: Color(0xFFE8E5ED),
                    child: Center(child: CircularProgressIndicator()),
                  ),
      ),
    );
  }

  Future<void> _load() async {
    _cancel = CancelHandle();
    final request = ImageRequest(
      url: widget.url,
      referer: widget.referer,
      variant: widget.variant,
      targetPixels: widget.targetPixels,
    );
    try {
      final bytes = await ref.read(imagePipelineProvider).load(
            request,
            source: widget.source,
            cancelHandle: _cancel,
          );
      if (!mounted) return;
      setState(() => _bytes = bytes);
    } catch (error) {
      if (!mounted || (_cancel?.token.isCancelled ?? false)) return;
      setState(() => _error = error);
    }
  }
}
