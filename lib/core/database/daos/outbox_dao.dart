// lib/core/database/daos/outbox_dao.dart
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [OutboxTable])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<int> enqueue(OutboxTableCompanion entry) {
    return into(outboxTable).insert(entry);
  }

  Stream<List<OutboxRow>> watchPending({required String companyId}) {
    return (select(outboxTable)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.status.isIn(['pending', 'failed', 'sending']))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<Map<String, int>> stats({required String companyId}) async {
    final rows = await (select(outboxTable)
          ..where((t) => t.companyId.equals(companyId)))
        .get();

    final stats = <String, int>{};
    for (final row in rows) {
      stats[row.status] = (stats[row.status] ?? 0) + 1;
    }
    return stats;
  }

  Future<int> recoverStaleLeases() async {
    final now = DateTime.now().toUtc();
    return (update(outboxTable)..where((t) =>
            t.status.equals('sending') &
            t.leaseUntil.isSmallerThanValue(now.toIso8601String())))
        .write(
      OutboxTableCompanion(
        status: const Value('failed'),
        lastError: const Value('انتهت مهلة محاولة سابقة'),
        leaseUntil: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markSynced(int seq) async {
    await (delete(outboxTable)..where((t) => t.seq.equals(seq))).go();
  }

  Future<void> markConflict({
    required int seq,
    required String error,
    int? httpStatus,
  }) async {
    final now = DateTime.now().toUtc();
    await (update(outboxTable)..where((t) => t.seq.equals(seq))).write(
      OutboxTableCompanion(
        status: const Value('conflict'),
        lastError: Value(error),
        lastHttpStatus: Value(httpStatus),
        retryable: const Value(false),
        leaseUntil: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markFailed({
    required int seq,
    required String error,
    int? httpStatus,
    Duration? retryAfter,
  }) async {
    final row =
        await (select(outboxTable)..where((t) => t.seq.equals(seq))).getSingle();
    final now = DateTime.now().toUtc();
    final nextAttempt = now.add(retryAfter ?? _backoffDelay(row.attempts));

    await (update(outboxTable)..where((t) => t.seq.equals(seq))).write(
      OutboxTableCompanion(
        status: const Value('failed'),
        attempts: Value(row.attempts + 1),
        lastError: Value(error),
        lastHttpStatus: Value(httpStatus),
        nextAttemptAt: Value(nextAttempt),
        leaseUntil: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Duration _backoffDelay(int attempts) {
    final base = 5 * (1 << attempts.clamp(0, 8));
    return Duration(seconds: base.clamp(5, 900));
  }
}
