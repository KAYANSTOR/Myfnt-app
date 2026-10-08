import 'dart:async';
import '../database/app_database.dart';
import 'api/api_client.dart';
import 'models/sync_result.dart';
import 'workers/pull_worker.dart';
import 'workers/push_worker.dart';

class SyncEngine {
  SyncEngine({required this.db, required this.api}) : _pushWorker = PushWorker(db: db, api: api), _pullWorker = PullWorker(db: db, api: api);
  final AppDatabase db;
  final ApiClient api;
  final PushWorker _pushWorker;
  final PullWorker _pullWorker;
  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  bool _running = false;
  bool get isRunning => _running;

  Future<SyncResult> syncNow() async {
    if (_running) return const SyncResult(status: SyncStatus.partial, error: 'دورة مزامنة جارية بالفعل');
    if (!api.isEnabled) return const SyncResult(status: SyncStatus.idle, error: 'النقل غير مفعّل (Mock). ربط Laravel مطلوب.');
    _running = true; _statusController.add(SyncStatus.running); final start = DateTime.now();
    try {
      final pushed = await _pushWorker.processBatch();
      final pulled = await _pullWorker.pull();
      final status = pushed.failed > 0 || pushed.conflicts > 0 || pulled.conflicts > 0 ? SyncStatus.partial : SyncStatus.success;
      _statusController.add(status);
      return SyncResult(status: status, pushed: pushed.processed, pulled: pulled.applied, conflicts: pushed.conflicts + pulled.conflicts, failed: pushed.failed, duration: DateTime.now().difference(start));
    } catch (error) {
      _statusController.add(SyncStatus.failed);
      return SyncResult(status: SyncStatus.failed, error: error.toString(), duration: DateTime.now().difference(start));
    } finally { _running = false; }
  }
  void dispose() => _statusController.close();
}
