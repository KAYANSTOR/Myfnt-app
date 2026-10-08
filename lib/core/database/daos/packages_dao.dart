import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'packages_dao.g.dart';

@DriftAccessor(tables: [
  BookingPackagesTable,
  BookingPackageVersionsTable,
  BookingTypesTable,
])
class PackagesDao extends DatabaseAccessor<AppDatabase>
    with _$PackagesDaoMixin {
  PackagesDao(super.db);

  Stream<List<BookingPackageRow>> watchAll({required String companyId}) =>
      (select(bookingPackagesTable)
            ..where((t) => t.companyId.equals(companyId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
          .watch();

  Stream<List<BookingPackageRow>> watchActive({required String companyId}) =>
      (select(bookingPackagesTable)
            ..where((t) => t.companyId.equals(companyId) & t.status.equals('active'))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<List<BookingPackageRow>> getAll({required String companyId}) =>
      (select(bookingPackagesTable)
            ..where((t) => t.companyId.equals(companyId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<BookingPackageRow?> getById(String id) =>
      (select(bookingPackagesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<BookingPackageRow?> getByName({required String companyId, required String name, String? excludeId}) {
    final q = select(bookingPackagesTable)
      ..where((t) => t.companyId.equals(companyId) & t.name.equals(name));
    if (excludeId != null) q.where((t) => t.id.equals(excludeId).not());
    return q.getSingleOrNull();
  }

  Future<int> maxSortOrder(String companyId) async {
    final q = selectOnly(bookingPackagesTable)
      ..addColumns([bookingPackagesTable.sortOrder.max()])
      ..where(bookingPackagesTable.companyId.equals(companyId));
    return (await q.getSingle()).read(bookingPackagesTable.sortOrder.max()) ?? 0;
  }

  Future<int> insert(BookingPackagesTableCompanion entry) => into(bookingPackagesTable).insert(entry);
  Future<bool> updatePackage(BookingPackagesTableCompanion entry) => update(bookingPackagesTable).replace(entry);
  Future<int> setStatus({required String id, required String status, required DateTime at}) =>
      (update(bookingPackagesTable)..where((t) => t.id.equals(id))).write(
        BookingPackagesTableCompanion(status: Value(status), updatedAt: Value(at)));
  Future<int> insertVersion(BookingPackageVersionsTableCompanion entry) => into(bookingPackageVersionsTable).insert(entry);
  Future<List<BookingPackageVersionRow>> getVersionsForPackage(String packageId) =>
      (select(bookingPackageVersionsTable)..where((t) => t.packageId.equals(packageId))..orderBy([(t) => OrderingTerm.desc(t.version)])).get();
  Future<BookingPackageVersionRow?> getLatestVersion(String packageId) =>
      (select(bookingPackageVersionsTable)..where((t) => t.packageId.equals(packageId))..orderBy([(t) => OrderingTerm.desc(t.version)])..limit(1)).getSingleOrNull();
  Stream<List<BookingTypeRow>> watchTypes({required String companyId}) =>
      (select(bookingTypesTable)..where((t) => t.companyId.equals(companyId) | t.companyId.isNull())..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  Future<BookingTypeRow?> getTypeByCode({required String companyId, required String code}) =>
      (select(bookingTypesTable)..where((t) => t.companyId.equals(companyId) & t.code.equals(code))).getSingleOrNull();
  Future<int> insertType(BookingTypesTableCompanion entry) => into(bookingTypesTable).insert(entry);
}
