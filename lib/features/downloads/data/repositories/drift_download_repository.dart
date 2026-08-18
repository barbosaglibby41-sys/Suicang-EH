import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/network_exception.dart';
import '../../../../core/network/site_http_client.dart';
import '../../../gallery/domain/entities/gallery.dart';
import '../../../gallery/domain/entities/gallery_key.dart';
import '../../../gallery/domain/entities/gallery_tag.dart';
import '../../../gallery/domain/repositories/gallery_repository.dart';
import '../../domain/entities/download_request.dart';
import '../../domain/entities/download_task.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_file_store.dart';

class DriftDownloadRepository implements DownloadRepository {
  DriftDownloadRepository({
    required AppDatabase database,
    required SiteHttpClient client,
    required DownloadFileStore fileStore,
    required GalleryRepository galleryRepository,
    this.maxConcurrentTasks = 2,
  })  : _database = database,
        _client = client,
        _fileStore = fileStore,
        _galleryRepository = galleryRepository;

  final AppDatabase _database;
  final SiteHttpClient _client;
  final DownloadFileStore _fileStore;
  final GalleryRepository _galleryRepository;
  final int maxConcurrentTasks;
  final _workers = <String, Future<void>>{};
  final _cancellations = <String, CancelToken>{};

  @override
  Stream<List<DownloadTask>> watchAll() {
    return (_database.select(_database.downloadTasks)
          ..orderBy([OrderingTerm.desc(_database.downloadTasks.updatedAt)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList(growable: false));
  }

  @override
  Future<DownloadTask?> enqueue(DownloadRequest request) async {
    if (request.pageUrls.isEmpty) return null;
    final existing = await (_database.select(_database.downloadTasks)
          ..where(
            (table) =>
                table.source.equals(request.gallery.key.source.storageValue) &
                table.gid.equals(request.gallery.key.gid) &
                table.status.isNotIn(['cancelled', 'failed']),
          ))
        .getSingleOrNull();
    if (existing != null) return _fromRow(existing);

    final id = const Uuid().v4();
    final now = DateTime.now().toUtc();
    final folder = await _fileStore.directoryFor(request.gallery.key);
    await _database.transaction(() async {
      await _upsertGallery(request.gallery);
      await _database.into(_database.downloadTasks).insert(
            DownloadTasksCompanion.insert(
              id: id,
              source: request.gallery.key.source.storageValue,
              gid: request.gallery.key.gid,
              status: DownloadStatus.queued.name,
              totalPages: Value(request.pageUrls.length),
              targetDirectory: Value(folder.path),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database.batch((batch) {
        batch.insertAll(
          _database.downloadPages,
          [
            for (var index = 0; index < request.pageUrls.length; index++)
              DownloadPagesCompanion.insert(
                taskId: id,
                pageIndex: index,
                pageUrl: Value(request.pageUrls[index].toString()),
                status: 'queued',
                updatedAt: now,
              ),
          ],
        );
      });
    });
    unawaited(_schedule());
    return DownloadTask(
      id: id,
      galleryKey: request.gallery.key,
      totalPages: request.pageUrls.length,
      completedPages: 0,
      status: DownloadStatus.queued,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> pause(String id) async {
    _cancellations.remove(id)?.cancel('Download paused by user.');
    await _setTaskStatus(id, DownloadStatus.paused);
  }

  @override
  Future<void> resume(String id) async {
    await _setTaskStatus(id, DownloadStatus.queued, clearFailure: true);
    unawaited(_schedule());
  }

  @override
  Future<void> retry(String id) async {
    await _setTaskStatus(id, DownloadStatus.queued, clearFailure: true);
    unawaited(_schedule());
  }

  @override
  Future<void> cancel(String id, {required bool deleteFiles}) async {
    final task = await (_database.select(_database.downloadTasks)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    if (task == null) return;
    _cancellations.remove(id)?.cancel('Download cancelled by user.');
    await _setTaskStatus(id, DownloadStatus.cancelled);
    if (deleteFiles) {
      await _fileStore.deleteDirectory(
        GalleryKey(
          source: SiteSource.fromStorageValue(task.source),
          gid: task.gid,
        ),
      );
      await (_database.delete(_database.downloadPages)
            ..where((table) => table.taskId.equals(id)))
          .go();
    }
  }

  @override
  Future<void> recoverInterrupted() async {
    await (_database.update(_database.downloadTasks)
          ..where(
              (table) => table.status.equals(DownloadStatus.downloading.name)))
        .write(
      DownloadTasksCompanion(
        status: const Value(DownloadStatus.queued.name),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    final pendingPages = await (_database.select(_database.downloadPages)
          ..where((table) =>
              table.status.equals('queued') |
              table.status.equals('downloading')))
        .get();
    for (final page in pendingPages) {
      final localPath = page.localPath;
      if (localPath == null) continue;
      final file = File(localPath);
      if (!await file.exists()) continue;
      await (_database.update(_database.downloadPages)
            ..where((table) =>
                table.taskId.equals(page.taskId) &
                table.pageIndex.equals(page.pageIndex)))
          .write(
        DownloadPagesCompanion(
          byteCount: Value(await file.length()),
          status: const Value('completed'),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _updateCompletion(page.taskId);
    }
    await _schedule();
  }

  Future<void> _schedule() async {
    while (_workers.length < maxConcurrentTasks) {
      final next = await (_database.select(_database.downloadTasks)
            ..where((table) => table.status.equals(DownloadStatus.queued.name))
            ..orderBy([OrderingTerm.asc(_database.downloadTasks.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      if (next == null || _workers.containsKey(next.id)) return;
      final worker = _run(next.id);
      _workers[next.id] = worker;
      unawaited(worker.whenComplete(() {
        _workers.remove(next.id);
        unawaited(_schedule());
      }));
    }
  }

  Future<void> _run(String id) async {
    final task = await (_database.select(_database.downloadTasks)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    if (task == null) return;
    final source = SiteSource.fromStorageValue(task.source);
    final key = GalleryKey(source: source, gid: task.gid);
    await _fileStore.removePartFiles(key);
    final cancelToken = CancelToken();
    _cancellations[id] = cancelToken;
    await _setTaskStatus(id, DownloadStatus.downloading);
    try {
      final pages = await (_database.select(_database.downloadPages)
            ..where((table) => table.taskId.equals(id))
            ..orderBy([OrderingTerm.asc(_database.downloadPages.pageIndex)]))
          .get();
      for (final page in pages) {
        final current = await _taskStatus(id);
        if (current != DownloadStatus.downloading) return;
        if (page.status == 'completed') continue;
        final pageUrl = Uri.tryParse(page.pageUrl ?? '');
        if (pageUrl == null) throw StateError('Download page URL is missing.');
        final url = await _galleryRepository.resolveImageUrl(pageUrl);
        final target = await _fileStore.pageFile(key, page.pageIndex, url);
        await (_database.update(_database.downloadPages)
              ..where((table) =>
                  table.taskId.equals(id) &
                  table.pageIndex.equals(page.pageIndex)))
            .write(
          DownloadPagesCompanion(
            localPath: Value(target.path),
            status: const Value('downloading'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
        final bytes = await _client.getBytes(
          url,
          source: source,
          acceptsImages: true,
          cancelToken: cancelToken,
        );
        final data = bytes.data;
        if (data == null || data.isEmpty)
          throw StateError('Downloaded page is empty.');
        final temporary = File('${target.path}.part');
        await temporary.writeAsBytes(data, flush: true);
        await temporary.rename(target.path);
        await (_database.update(_database.downloadPages)
              ..where((table) =>
                  table.taskId.equals(id) &
                  table.pageIndex.equals(page.pageIndex)))
            .write(
          DownloadPagesCompanion(
            localPath: Value(target.path),
            byteCount: Value(data.length),
            status: const Value('completed'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
        await _updateCompletion(id);
      }
      await _setTaskStatus(id, DownloadStatus.completed);
    } on NetworkException catch (error) {
      final current = await _taskStatus(id);
      if (current == DownloadStatus.downloading &&
          error.kind != NetworkFailureKind.cancelled) {
        await _setTaskStatus(id, DownloadStatus.failed,
            failureCode: 'download_failed');
      }
    } catch (_) {
      final current = await _taskStatus(id);
      if (current == DownloadStatus.downloading) {
        await _setTaskStatus(id, DownloadStatus.failed,
            failureCode: 'download_failed');
      }
    } finally {
      _cancellations.remove(id);
    }
  }

  Future<void> _updateCompletion(String id) async {
    final completed = await (_database.select(_database.downloadPages)
          ..where((table) =>
              table.taskId.equals(id) & table.status.equals('completed')))
        .get()
        .then((rows) => rows.length);
    await (_database.update(_database.downloadTasks)
          ..where((table) => table.id.equals(id)))
        .write(
      DownloadTasksCompanion(
        completedPages: Value(completed),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> _setTaskStatus(
    String id,
    DownloadStatus status, {
    String? failureCode,
    bool clearFailure = false,
  }) {
    return (_database.update(_database.downloadTasks)
          ..where((table) => table.id.equals(id)))
        .write(
      DownloadTasksCompanion(
        status: Value(status.name),
        failureCode: clearFailure ? const Value(null) : Value(failureCode),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<DownloadStatus?> _taskStatus(String id) async {
    final row = await (_database.select(_database.downloadTasks)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : DownloadStatus.values.byName(row.status);
  }

  Future<void> _upsertGallery(Gallery gallery) => _database
      .into(_database.galleries)
      .insertOnConflictUpdate(_galleryCompanion(gallery));

  GalleriesCompanion _galleryCompanion(Gallery gallery) =>
      GalleriesCompanion.insert(
        source: gallery.key.source.storageValue,
        gid: gallery.key.gid,
        title: gallery.title,
        uploader: Value(gallery.uploader),
        category: Value(gallery.category),
        thumbnailUrl: Value(gallery.thumbnailUrl?.toString()),
        sourceUrl: Value(gallery.sourceUrl?.toString()),
        pageCount: Value(gallery.pageCount),
        tagsJson: Value(jsonEncode([
          for (final tag in gallery.tags)
            {
              'namespace': tag.namespace,
              'key': tag.key,
              'translatedName': tag.translatedName
            }
        ])),
        rating: Value(gallery.rating),
        postedAt: Value(gallery.postedAt),
        updatedAt: DateTime.now().toUtc(),
      );

  DownloadTask _fromRow(DownloadTaskData row) => DownloadTask(
        id: row.id,
        galleryKey: GalleryKey(
            source: SiteSource.fromStorageValue(row.source), gid: row.gid),
        totalPages: row.totalPages,
        completedPages: row.completedPages,
        status: DownloadStatus.values.byName(row.status),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        failureCode: row.failureCode,
      );
}
