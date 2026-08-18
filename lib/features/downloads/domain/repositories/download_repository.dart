import '../entities/download_request.dart';
import '../entities/download_task.dart';

abstract interface class DownloadRepository {
  Stream<List<DownloadTask>> watchAll();
  Future<DownloadTask?> enqueue(DownloadRequest request);
  Future<void> pause(String id);
  Future<void> resume(String id);
  Future<void> retry(String id);
  Future<void> cancel(String id, {required bool deleteFiles});
  Future<void> recoverInterrupted();
}
