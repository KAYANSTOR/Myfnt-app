import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// DAO — Data Access Object للحجوزات
/// Controllers تتعامل مع Repository وليس مع هذا مباشرة
@DriftAccessor(tables: [BookingsTable])
class BookingsDao extends DatabaseAccessor<AppDatabase>
    with _$BookingsDaoMixin {
  BookingsDao(super.db);

  // ── قراءة ──────────────────────────────────────────

  /// Stream تفاعلي لجميع الحجوزات — يتحدث تلقائياً عند أي تغيير
  Stream<List<BookingsTableData>> watchAll() => (select(
    bookingsTable,
  )..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  /// Stream تفاعلي لحجوزات شهر محدد
  Stream<List<BookingsTableData>> watchByMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (select(bookingsTable)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  /// Stream تفاعلي ليوم محدد
  Stream<List<BookingsTableData>> watchByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(
      bookingsTable,
    )..where((t) => t.date.isBetweenValues(start, end))).watch();
  }

  /// قراءة مرة واحدة (للاختبارات)
  Future<List<BookingsTableData>> getAll() => (select(
    bookingsTable,
  )..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  Future<BookingsTableData?> getById(int id) =>
      (select(bookingsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  // ── كتابة ──────────────────────────────────────────

  Future<int> insert(BookingsTableCompanion entry) =>
      into(bookingsTable).insert(entry);

  Future<bool> update_(BookingsTableCompanion entry) =>
      update(bookingsTable).replace(entry);

  Future<int> delete_(int id) =>
      (delete(bookingsTable)..where((t) => t.id.equals(id))).go();
}

/// DAO للعملاء
@DriftAccessor(tables: [CustomersTable])
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Stream<List<CustomersTableData>> watchAll() => (select(
    customersTable,
  )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<int> insert(CustomersTableCompanion entry) =>
      into(customersTable).insert(entry);
}

/// قاعدة البيانات الرئيسية
@DriftDatabase(
  tables: [BookingsTable, CustomersTable],
  daos: [BookingsDao, CustomersDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Migrations مستقبلية تُضاف هنا
    },
  );
}

/// فتح اتصال SQLite في خلفية Isolate منفصلة
/// بحيث لا تؤثر عمليات DB الثقيلة على UI
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'mivent_db',
    native: DriftNativeOptions(shareAcrossIsolates: true),
  );
}
