import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../features/gallery/domain/entities/gallery_key.dart';
import '../../core/network/site_http_client.dart';
import 'decode_scheduler.dart';
import 'disk_image_cache.dart';
import 'image_decoder.dart';
import 'image_request.dart';
import 'media_kind.dart';
import 'memory_image_cache.dart';

class ImagePipeline {
  ImagePipeline({
    required SiteHttpClient client,
    DiskImageCache? diskCache,
    MemoryImageCache<Uint8List>? memoryCache,
    ImageDecoder decoder = const ImageDecoder(),
    DecodeScheduler? decodeScheduler,
  })  : _client = client,
        _diskCache = diskCache ?? DiskImageCache(),
        _memoryCache = memoryCache ?? MemoryImageCache<Uint8List>(),
        _decoder = decoder,
        _decodeScheduler = decodeScheduler ?? DecodeScheduler();

  final SiteHttpClient _client;
  final DiskImageCache _diskCache;
  final MemoryImageCache<Uint8List> _memoryCache;
  final ImageDecoder _decoder;
  final DecodeScheduler _decodeScheduler;
  final _inFlight = <String, Future<DecodedImage>>{};

  Future<Uint8List> load(
    ImageRequest request, {
    required SiteSource source,
    CancelHandle? cancelHandle,
  }) async {
    final memory = _memoryCache.get(request.cacheKey);
    if (memory != null) {
      return memory;
    }
    final existing = _inFlight[request.cacheKey];
    final decoded = existing ??
        _decodeRequest(
          request,
          source: source,
          cancelHandle: cancelHandle,
        );
    if (existing == null) {
      _inFlight[request.cacheKey] = decoded;
    }
    try {
      final image = await decoded;
      _memoryCache.put(
        request.cacheKey,
        image.bytes,
        costBytes: image.estimatedCostBytes,
      );
      return image.bytes;
    } finally {
      if (identical(_inFlight[request.cacheKey], decoded)) {
        _inFlight.remove(request.cacheKey);
      }
    }
  }

  Future<void> prefetch(
    Iterable<ImageRequest> requests, {
    required SiteSource source,
  }) async {
    for (final request in requests) {
      await load(request, source: source);
    }
  }

  void remove(ImageRequest request) {
    _memoryCache.remove(request.cacheKey);
    _inFlight.remove(request.cacheKey);
  }

  void clearMemory() => _memoryCache.clear();
  Future<void> clearDisk() => _diskCache.clear();

  Future<DecodedImage> _decodeRequest(
    ImageRequest request, {
    required SiteSource source,
    CancelHandle? cancelHandle,
  }) async {
    final bytes = await _loadRawBytes(
      request,
      source: source,
      cancelHandle: cancelHandle,
    );
    if (MediaKindResolver.fromUri(request.url) != MediaKind.image) {
      return DecodedImage(
        bytes: bytes,
        width: 1,
        height: bytes.length,
      );
    }
    return _decodeScheduler.schedule(
      visible: cancelHandle != null,
      operation: () => _decoder.decode(
        bytes,
        targetPixels: request.decodeTargetPixels,
      ),
    );
  }

  Future<Uint8List> _loadRawBytes(
    ImageRequest request, {
    required SiteSource source,
    CancelHandle? cancelHandle,
  }) async {
    if (request.url.isScheme('file')) {
      final file = File.fromUri(request.url);
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError('The local image file was empty.');
      }
      return bytes;
    }
    final disk = await _diskCache.read(request);
    if (disk != null) {
      return disk;
    }
    final response = await _client.getBytes(
      request.url,
      source: source,
      referer: request.referer,
      acceptsImages: true,
      cancelToken: cancelHandle?.token,
    );
    final contentType = response.headers.value('content-type')?.toLowerCase();
    if (contentType != null && !contentType.startsWith('image/')) {
      throw StateError('The image response was not an image.');
    }
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('The image response was empty.');
    }
    await _diskCache.write(request, bytes);
    return Uint8List.fromList(bytes);
  }
}

class CancelHandle {
  CancelHandle([CancelToken? token]) : token = token ?? CancelToken();

  final CancelToken token;

  void cancel([Object? reason]) => token.cancel(reason);
}
