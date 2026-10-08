// lib/core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/bookings_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/payments_dao.dart';
import 'converters/json_converter.dart';
import 'converters/utc_datetime_converter.dart';
import 'converters/uuid_converter.dart';
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
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

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
            await customStatement('PRAGMA foreign_keys = OFF');
            const tablesToDrop = [
              'outbox',
              'booking_audit',
              'booking_details',
              'payments',
              'bookings',
              'customers',
              'company_settings',
              'users',
              'companies',
            ];
            for (final t in tablesToDrop) {
              await customStatement('DROP TABLE IF EXISTS $t');
            }
            await customStatement('PRAGMA foreign_keys = ON');
            await m.createAll();
            await _createIndexes();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = NORMAL');
          await customStatement('PRAGMA cache_size = -8000');
          await customStatement('PRAGMA busy_timeout = 5000');
          await customStatement('PRAGMA journal_size_limit = 10485760');
        },
      );

  Future<void> _createIndexes() async {
    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_date '
          'ON bookings(company_id, event_date)',
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_status '
          'ON bookings(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_customer '
          'ON bookings(company_id, customer_id)',
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_no '
          'ON bookings(company_id, booking_no)',
      'CREATE INDEX IF NOT EXISTS idx_booking_details_booking '
          'ON booking_details(booking_id)',
      'CREATE INDEX IF NOT EXISTS idx_payments_company_booking '
          'ON payments(company_id, booking_id)',
      'CREATE INDEX IF NOT EXISTS idx_payments_company_status '
          'ON payments(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_payments_company_posted '
          'ON payments(company_id, posted_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_customers_company_phone '
          'ON customers(company_id, phone_key)',
      'CREATE INDEX IF NOT EXISTS idx_customers_company_name '
          'ON customers(company_id, name_key)',
      'CREATE INDEX IF NOT EXISTS idx_customers_company_no '
          'ON customers(company_id, customer_no)',
      'CREATE INDEX IF NOT EXISTS idx_booking_audit_booking '
          'ON booking_audit(booking_id, happened_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_outbox_company_status_created '
          'ON outbox(company_id, status, created_at ASC)',
      'CREATE INDEX IF NOT EXISTS idx_outbox_entity_key '
          'ON outbox(entity_key)',
    ];
    for (final sql in indexes) {
      await customStatement(sql);
    }
  }

  Future<void> performMaintenance() async {
    await customStatement('PRAGMA incremental_vacuum');
    await customStatement('PRAGMA optimize');
    await customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'myfnt_db',
    native: DriftNativeOptions(shareAcrossIsolates: true),
  );
}
