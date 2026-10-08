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
// ملاحظة: عند الترقية من schemaVersion 1 → 2، تُحذف جميع الجداول
// القديمة ويُعاد إنشاؤها (لأن الفرق جذري — UUID، minor units، إلخ).
// هذا مقبول في مرحلة ما قبل الإنتاج.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/bookings_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/payments_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// قاعدة بيانات Myfnt — مركز كل البيانات.
///
/// تُفتح مرة واحدة عبر `appDatabaseProvider` (Riverpod).
@DriftDatabase(
  tables: [
    // الشركة والمستخدمين والإعدادات
    CompaniesTable,
    UsersTable,
    CompanySettingsTable,
    // العملاء
    CustomersTable,
    // الحجوزات
    BookingsTable,
    BookingDetailsTable,
    // الدفعات
    PaymentsTable,
    // التدقيق
    BookingAuditTable,
    // المزامنة
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

  /// استراتيجية الترحيل.
  ///
  /// من 1 → 2: تغيير جذري في النموذج (UUID, minor units).
  /// سنحذف كل الجداول القديمة ونُعيد إنشاءها.
  /// البيانات المحلية القديمة تُفقد — مقبول (pre-production).
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // Step 1: عطّل FK مؤقتاً (نحتاج حذف الجداول بترتيب).
            await customStatement('PRAGMA foreign_keys = OFF');

            // Step 2: احذف كل الجداول (الأطفال قبل الآباء).
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

            // Step 3: أعد تفعيل FK.
            await customStatement('PRAGMA foreign_keys = ON');

            // Step 4: أعد إنشاء الجداول.
            await m.createAll();
            await _createIndexes();
          }
        },
        beforeOpen: (details) async {
          // تفعيل Foreign Keys (مطلوب بعد كل فتح).
          await customStatement('PRAGMA foreign_keys = ON');

          // ============ إعدادات الأداء ============
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = NORMAL');
          await customStatement('PRAGMA cache_size = -8000');
          await customStatement('PRAGMA busy_timeout = 5000');
          await customStatement('PRAGMA journal_size_limit = 10485760');
        },
      );

  /// الفهارس — تُنشأ بعد `createAll`.
  ///
  /// القاعدة: كل استعلام متكرر يجب أن يكون مفهرساً.
  Future<void> _createIndexes() async {
    const indexes = [
      // ============ Bookings ============
      // الاستعلام الأكثر شيوعاً: حجوزات شركة في تاريخ معين.
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_date '
          'ON bookings(company_id, event_date)',
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_status '
          'ON bookings(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_customer '
          'ON bookings(company_id, customer_id)',
      'CREATE INDEX IF NOT EXISTS idx_bookings_company_no '
          'ON bookings(company_id, booking_no)',

      // ============ Booking Details ============
      'CREATE INDEX IF NOT EXISTS idx_booking_details_booking '
          'ON booking_details(booking_id)',

      // ============ Payments ============
      'CREATE INDEX IF NOT EXISTS idx_payments_company_booking '
          'ON payments(company_id, booking_id)',
      'CREATE INDEX IF NOT EXISTS idx_payments_company_status '
          'ON payments(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_payments_company_posted '
          'ON payments(company_id, posted_at DESC)',

      // ============ Customers ============
      'CREATE INDEX IF NOT EXISTS idx_customers_company_phone '
          'ON customers(company_id, phone_key)',
      'CREATE INDEX IF NOT EXISTS idx_customers_company_name '
          'ON customers(company_id, name_key)',
      'CREATE INDEX IF NOT EXISTS idx_customers_company_no '
          'ON customers(company_id, customer_no)',

      // ============ Audit ============
      'CREATE INDEX IF NOT EXISTS idx_booking_audit_booking '
          'ON booking_audit(booking_id, happened_at DESC)',

      // ============ Outbox ============
      // الأهم للمزامنة: طابور FIFO بحسب الحالة.
      'CREATE INDEX IF NOT EXISTS idx_outbox_company_status_created '
          'ON outbox(company_id, status, created_at ASC)',
      'CREATE INDEX IF NOT EXISTS idx_outbox_entity_key '
          'ON outbox(entity_key)',
    ];

    for (final sql in indexes) {
      await customStatement(sql);
    }
  }

  /// صيانة دورية (يمكن استدعاؤها من الإعدادات).
  Future<void> performMaintenance() async {
    await customStatement('PRAGMA incremental_vacuum');
    await customStatement('PRAGMA optimize');
    await customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}

/// فتح اتصال SQLite في Isolate منفصل.
///
/// - `myfnt_db` — اسم جديد (بدلاً من `mivent_db` القديم).
/// - `shareAcrossIsolates: true` — للعمل مع Background Isolate.
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'myfnt_db',
    native: DriftNativeOptions(shareAcrossIsolates: true),
  );
}
