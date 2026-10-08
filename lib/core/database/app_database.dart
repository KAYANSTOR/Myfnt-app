// lib/core/database/app_database.dart
//
// قاعدة بيانات Myfnt — الكلاس الرئيسي.
//
// Contract:
//   - schemaVersion = 2 (ترقية من 1).
//   - WAL Mode مفعّل.
//   - Foreign Keys مفعّلة.
//   - اسم الملف: `myfnt_db.sqlite`.
//
// ملاحظة: بعد تعديل tables/DAOs يجب تشغيل:
//   dart run build_runner build --delete-conflicting-outputs

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'converters/json_converter.dart';
import 'converters/utc_datetime_converter.dart';
import 'converters/uuid_converter.dart';
import 'daos/bookings_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/payments_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CompaniesTable,
    UsersTable,
    CompanySettingsTable,
    CustomersTable,
    BookingsTable,
    BookingDetailsTable,
    PaymentsTable,
    BookingAuditTable,
    OutboxTable,
  ],
  daos: [
    BookingsDao,
    CustomersDao,
    PaymentsDao,
    OutboxDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // Session 2: drop everything and recreate (no production data yet).
            for (final table in allTables) {
              await m.deleteTable(table.actualTableName);
            }
            await m.createAll();
            await _createIndexes();
          }
        },
        beforeOpen: (details) async {
          // WAL + Foreign Keys + performance PRAGMAs.
          await customStatement('PRAGMA journal_mode=WAL');
          await customStatement('PRAGMA foreign_keys=ON');
          await customStatement('PRAGMA synchronous=NORMAL');
          await customStatement('PRAGMA temp_store=MEMORY');
          await customStatement('PRAGMA mmap_size=268435456');
        },
      );

  Future<void> _createIndexes() async {
    // Companies
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_companies_name ON companies(name)',
    );

    // Users
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_users_company ON users(company_id)',
    );

    // Customers
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_customers_company ON customers(company_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_customers_search ON customers(search_text)',
    );

    // Bookings — hot paths
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_date ON bookings(company_id, event_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_bookings_customer ON bookings(customer_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_bookings_search ON bookings(search_text)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_bookings_updated ON bookings(updated_at)',
    );

    // Payments
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_payments_booking ON payments(booking_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_payments_company ON payments(company_id)',
    );

    // Outbox
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_status ON outbox(status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_created ON outbox(created_at)',
    );

    // Audit
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_audit_booking ON booking_audit(booking_id)',
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'myfnt_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
