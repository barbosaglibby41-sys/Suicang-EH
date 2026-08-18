import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'image_request.dart';

class DiskImageCache {
  DiskImageCache({this.ttl = const Duration(days: 7)});

  final Duration ttl;
  Directory? _directory;

  Future<Uint8List?> read(ImageRequest request) async {
    final file = await _fileFor(request);
    if (!await file.exists()) {
      return null;
    }
    final modified = await file.lastModified();
    if (DateTime.now().difference(modified) > ttl) {
      await _deleteQuietly(file);
      return null;
    }
    return file.readAsBytes();
  }

  Future<void> write(ImageRequest request, List<int> bytes) async {
    final file = await _fileFor(request);
    final temporary = File('${file.path}.part');
    await temporary.writeAsBytes(bytes, flush: true);
    await temporary.rename(file.path);
  }

  Future<void> remove(ImageRequest request) async {
    await _deleteQuietly(await _fileFor(request));
  }

  Future<void> clear() async {
    final directory = await _cacheDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    _directory = null;
  }

  Future<File> _fileFor(ImageRequest request) async {
    final directory = await _cacheDirectory();
    final digest = sha256.convert(request.cacheKey.codeUnits).toString();
    return File(path.join(directory.path, '$digest.bin'));
  }

  Future<Directory> _cacheDirectory() async {
    final existing = _directory;
    if (existing != null) {
      return existing;
    }
    final root = await getTemporaryDirectory();
    final created = Directory(path.join(root.path, 'taro_eh', 'images'));
    await created.create(recursive: true);
    _directory = created;
    return created;
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // Cache cleanup must never fail a visible image request.
    }
  }
}
