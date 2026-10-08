import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/tables.dart';
import '../api/api_client.dart';
import '../models/sync_result.dart';

class PushWorker {
  PushWorker({required this.db, required this.api});
  final AppDatabase db;
  final ApiClient api;
  static const int _maxAttempts = 8;

  Future<int> recoverStaleLeases() async {
    final now = DateTime.now().toUtc();
    return (db.update(db.outboxTable)..where((t) => t.status.equals('sending') & t.leaseUntil.isSmallerThanValue(now))).write(OutboxTableCompanion(status: const Value('failed'), lastError: const Value('انتهت مهلة محاولة سابقة'), leaseUntil: const Value(null), updatedAt: Value(now)));
  }

  Future<PushResult> processBatch({int limit = 50}) async {
    if (!api.isEnabled) return PushResult.empty();
    await recoverStaleLeases();
    final batch = await _claimBatch(limit: limit);
    if (batch.isEmpty) return PushResult.empty();
    final payload = batch.map((row) => <String, dynamic>{'op_id': row.operationId, 'entity_type': row.entityType, 'entity_id': row.entityId, 'operation': row.operation, 'base_version': row.baseVersion, 'payload': row.payload}).toList();
    PushBatchResponse response;
    try { response = await api.push(payload); } catch (error) { await _failAll(batch, error.toString()); return PushResult(processed: 0, failed: batch.length, conflicts: 0); }
    if (!response.ok) { await _failAll(batch, response.message ?? 'Batch failed'); return PushResult(processed: 0, failed: batch.length, conflicts: 0); }
    return _processResults(batch, response);
  }

  Future<List<OutboxRow>> _claimBatch({required int limit}) async {
    final now = DateTime.now().toUtc();
    final leaseUntil = now.add(const Duration(seconds: 45));
    return db.transaction(() async {
      final candidates = await (db.select(db.outboxTable)..where((t) => t.status.isIn(['pending', 'failed']) & t.attempts.isSmallerThanValue(_maxAttempts) & (t.nextAttemptAt.isNull() | t.nextAttemptAt.isSmallerOrEqualValue(now)))..orderBy([(t) => OrderingTerm.asc(t.createdAt)])..limit(limit)).get();
      if (candidates.isEmpty) return <OutboxRow>[];
      final ids = candidates.map((row) => row.seq).toList();
      await (db.update(db.outboxTable)..where((t) => t.seq.isIn(ids))).write(OutboxTableCompanion(status: const Value('sending'), leaseUntil: Value(leaseUntil), updatedAt: Value(now)));
      return (db.select(db.outboxTable)..where((t) => t.seq.isIn(ids))..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    });
  }

  Future<void> _failAll(List<OutboxRow> batch, String error) async { for (final row in batch) await _markFailed(row, error); }
  Future<PushResult> _processResults(List<OutboxRow> batch, PushBatchResponse response) async {
    final byId = {for (final result in response.results) result.opId: result};
    var synced = 0, failed = 0, conflicts = 0;
    for (final row in batch) {
      final result = byId[row.operationId];
      if (result == null) { await _markFailed(row, 'الخادم لم يُرجع نتيجة لهذه العملية'); failed++; continue; }
      if (result.serverEntityId != null && result.serverEntityId!.toLowerCase() != row.entityId.toLowerCase()) { await _markFailed(row, 'IDENTITY_MISMATCH: ${row.entityId} != ${result.serverEntityId}'); failed++; continue; }
      switch (result.status) {
        case 'synced': case 'ok': case 'accepted': await db.outboxDao.markSynced(row.seq); synced++; break;
        case 'conflict': await db.outboxDao.markConflict(seq: row.seq, error: result.message ?? 'تعارض'); conflicts++; break;
        default: await _markFailed(row, result.message ?? 'Unknown status'); failed++;
      }
    }
    return PushResult(processed: synced, failed: failed, conflicts: conflicts);
  }
  Future<void> _markFailed(OutboxRow row, String error) => db.outboxDao.markFailed(seq: row.seq, error: error);
}
