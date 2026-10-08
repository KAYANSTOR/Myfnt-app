// lib/core/database/daos/payments_dao.dart
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [PaymentsTable])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  Stream<List<PaymentRow>> watchByBooking({
    required String companyId,
    required String bookingId,
  }) {
    return (select(paymentsTable)
          ..where((t) =>
              t.companyId.equals(companyId) & t.bookingId.equals(bookingId))
          ..orderBy([(t) => OrderingTerm.desc(t.postedAt)]))
        .watch();
  }

  Stream<List<PaymentRow>> watchAll({required String companyId}) {
    return (select(paymentsTable)
          ..where((t) => t.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.desc(t.postedAt)]))
        .watch();
  }

  Future<PaymentRow?> getById(String id) {
    return (select(paymentsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> sumActiveForBooking({
    required String companyId,
    required String bookingId,
  }) async {
    final query = selectOnly(paymentsTable)
      ..addColumns([
        paymentsTable.amountMinor.sum(),
        paymentsTable.direction,
      ])
      ..where(paymentsTable.companyId.equals(companyId) &
          paymentsTable.bookingId.equals(bookingId) &
          paymentsTable.status.equals('posted'))
      ..groupBy([paymentsTable.direction]);

    final rows = await query.get();
    var total = 0;
    for (final row in rows) {
      final amount = row.read(paymentsTable.amountMinor.sum()) ?? 0;
      final direction = row.read(paymentsTable.direction);
      if (direction == 'in') {
        total += amount;
      } else {
        total -= amount;
      }
    }
    return total;
  }

  Future<String?> nextReceiptNo(String companyId) async {
    final row = await (select(paymentsTable)
          ..where((t) => t.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.desc(t.receiptNo)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return '1';
    final n = int.tryParse(row.receiptNo) ?? 0;
    return (n + 1).toString();
  }

  Future<int> insert(PaymentsTableCompanion entry) {
    return into(paymentsTable).insert(entry);
  }

  Future<bool> updatePayment(PaymentsTableCompanion entry) {
    return update(paymentsTable).replace(entry);
  }
}
