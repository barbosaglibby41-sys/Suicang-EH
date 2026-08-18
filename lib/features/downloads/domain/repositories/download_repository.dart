import '../entities/download_task.dart';

abstract interface class DownloadRepository {
  Stream<List<DownloadTask>> watchAll();
  Future<void> pause(String id);
  Future<void> resume(String id);
  Future<void> cancel(String id, {required bool deleteFiles});
}
