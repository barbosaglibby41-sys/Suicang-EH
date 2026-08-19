import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/image/media_kind.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../domain/entities/reader_models.dart';

class ReaderMedia extends ConsumerStatefulWidget {
  const ReaderMedia({
    required this.url,
    required this.bytes,
    required this.source,
    required this.fit,
    required this.zoom,
    super.key,
  });

  final Uri url;
  final Uint8List bytes;
  final SiteSource source;
  final ReaderFit fit;
  final double zoom;

  @override
  ConsumerState<ReaderMedia> createState() => _ReaderMediaState();
}

class _ReaderMediaState extends ConsumerState<ReaderMedia> {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    if (MediaKindResolver.fromUri(widget.url) == MediaKind.video) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(covariant ReaderMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url &&
        MediaKindResolver.fromUri(widget.url) == MediaKind.video) {
      _disposeVideo();
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaKindResolver.fromUri(widget.url) != MediaKind.video) {
      return InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Transform.scale(
          scale: widget.zoom,
          child: Image.memory(
            widget.bytes,
            fit:
                widget.fit == ReaderFit.contain ? BoxFit.contain : BoxFit.cover,
            width: double.infinity,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
        ),
      );
    }
    final controller = _controller;
    if (_error != null)
      return const Center(child: Icon(Icons.video_file_outlined));
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            IconButton.filledTonal(
              onPressed: () => setState(() {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
              }),
              icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = widget.url.isScheme('file')
          ? VideoPlayerController.file(File.fromUri(widget.url))
          : VideoPlayerController.networkUrl(
              widget.url,
              httpHeaders: await _headers(),
            );
      _controller = controller;
      await controller.initialize();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<Map<String, String>> _headers() async {
    final cookies =
        await ref.read(authRepositoryProvider).cookiesFor(widget.source);
    if (cookies.isEmpty) return const {};
    return {
      'Cookie':
          cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; '),
    };
  }

  void _disposeVideo() {
    _controller?.dispose();
    _controller = null;
  }
}
