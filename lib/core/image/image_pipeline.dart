import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../features/gallery/domain/entities/gallery_key.dart';
import '../../core/network/site_http_client.dart';
import 'disk_image_cache.dart';
import 'image_request.dart';
import 'memory_image_cache.dart';

class ImagePipeline {
  ImagePipeline({
    required SiteHttpClient client,
    DiskImageCache? diskCache,
    MemoryImageCache<Uint8List>? memoryCache,
  })  : _client = client,
        _diskCache = diskCache ?? DiskImageCache(),
        _memoryCache = memoryCache ?? MemoryImageCache<Uint8List>();

  final SiteHttpClient _client;
  final DiskImageCache _diskCache;
  final MemoryImageCache<Uint8List> _memoryCache;
  final _inFlight = <String, Future<Uint8List>>{};

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
    if (existing != null) {
      return existing;
    }

    final future = _loadUncached(request, source: source, cancelHandle: cancelHandle);
    _inFlight[request.cacheKey] = future;
    try {
      final bytes = await future;
      _memoryCache.put(
        request.cacheKey,
        bytes,
        costBytes: bytes.length,
      );
      return bytes;
    } finally {
      _inFlight.remove(request.cacheKey);
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

  Future<Uint8List> _loadUncached(
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
