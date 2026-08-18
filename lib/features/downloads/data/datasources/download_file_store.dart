import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../gallery/domain/entities/gallery_key.dart';

class DownloadFileStore {
  Future<Directory> directoryFor(GalleryKey key) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(
      path.join(root.path, 'offline', key.source.storageValue, '${key.gid}'),
    );
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> pageFile(GalleryKey key, int index, Uri sourceUrl) async {
    final directory = await directoryFor(key);
    final extension = _extension(sourceUrl);
    return File(path.join(directory.path, '${(index + 1).toString().padLeft(4, '0')}.$extension'));
  }

  Future<void> deleteDirectory(GalleryKey key) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(
      path.join(root.path, 'offline', key.source.storageValue, '${key.gid}'),
    );
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  String _extension(Uri url) {
    final candidate = path.extension(url.path).replaceFirst('.', '').toLowerCase();
    return {'jpg', 'jpeg', 'png', 'webp', 'gif'}.contains(candidate)
        ? candidate
        : 'jpg';
  }
}
