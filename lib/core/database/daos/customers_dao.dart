// lib/core/database/daos/customers_dao.dart
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [CustomersTable])
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Stream<List<CustomerRow>> watchAll({required String companyId}) {
    return (select(customersTable)
          ..where((t) => t.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.asc(t.nameKey)]))
        .watch();
  }

  Future<CustomerRow?> getById(String id) {
    return (select(customersTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<CustomerRow>> searchByName({
    required String companyId,
    required String nameKey,
    int limit = 10,
  }) {
    return (select(customersTable)
          ..where((t) =>
              t.companyId.equals(companyId) & t.nameKey.equals(nameKey))
          ..limit(limit))
        .get();
  }

  Future<List<CustomerRow>> searchByPhone({
    required String companyId,
    required String phoneKey,
    int limit = 10,
  }) {
    return (select(customersTable)
          ..where((t) =>
              t.companyId.equals(companyId) & t.phoneKey.equals(phoneKey))
          ..limit(limit))
        .get();
  }

  Future<List<CustomerRow>> findDuplicates({
    required String companyId,
    required String nameKey,
    required String phoneKey,
    String? excludeId,
  }) {
    final q = select(customersTable)
      ..where((t) =>
          t.companyId.equals(companyId) &
          t.nameKey.equals(nameKey) &
          t.phoneKey.equals(phoneKey));
    if (excludeId != null) {
      q.where((t) => t.id.equals(excludeId).not());
    }
    return q.get();
  }

  Future<int> insert(CustomersTableCompanion entry) {
    return into(customersTable).insert(entry);
  }

  Future<bool> updateCustomer(CustomersTableCompanion entry) {
    return update(customersTable).replace(entry);
  }

  Future<String?> nextCustomerNo(String companyId) async {
    final row = await (select(customersTable)
          ..where((t) => t.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.desc(t.customerNo)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return '1';
    final n = int.tryParse(row.customerNo) ?? 0;
    return (n + 1).toString();
  }
}
