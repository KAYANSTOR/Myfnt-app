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
    PaymentAuditTable,
    OutboxTable,
    BookingPackagesTable,
    BookingPackageVersionsTable,
    BookingTypesTable,
    CalendarBlocksTable,
    AlertRulesTable,
    SmsTemplatesTable,
    SmsMessagesTable,
    SmsApprovalsTable,
    NotificationsTable,
    NotificationJobsTable,
    SyncConflictsTable,
    EntityTombstonesTable,
    LocalMetaTable,
    SnapshotsTable,
    CompanyMembershipsTable,
    PlansTable,
    CompanySubscriptionsTable,
    WalletsTable,
    JournalEntriesTable,
    JournalLinesTable,
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
  int get schemaVersion => 6;

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
            return;
          }
          if (from < 3) {
            await m.createTable(bookingPackagesTable);
            await m.createTable(bookingPackageVersionsTable);
            await m.createTable(bookingTypesTable);
            await m.createTable(calendarBlocksTable);
            await m.createTable(paymentAuditTable);
            await _createIndexes();
          }
          if (from < 4) {
            await m.createTable(alertRulesTable);
            await m.createTable(smsTemplatesTable);
            await m.createTable(smsMessagesTable);
            await m.createTable(smsApprovalsTable);
            await m.createTable(notificationsTable);
            await m.createTable(notificationJobsTable);
            await _createIndexes();
          }
          if (from < 5) {
            await m.createTable(syncConflictsTable);
            await m.createTable(entityTombstonesTable);
            await m.createTable(localMetaTable);
            await m.createTable(snapshotsTable);
            await _createIndexes();
          }
          if (from < 6) {
            await m.createTable(companyMembershipsTable);
            await m.createTable(plansTable);
            await m.createTable(companySubscriptionsTable);
            await m.createTable(walletsTable);
            await m.createTable(journalEntriesTable);
            await m.createTable(journalLinesTable);
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
      'CREATE INDEX IF NOT EXISTS idx_packages_company_status '
          'ON booking_packages(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_packages_company_sort '
          'ON booking_packages(company_id, sort_order)',
      'CREATE INDEX IF NOT EXISTS idx_package_versions_package '
          'ON booking_package_versions(package_id, version DESC)',
      'CREATE INDEX IF NOT EXISTS idx_booking_types_company '
          'ON booking_types(company_id, code)',
      'CREATE INDEX IF NOT EXISTS idx_calendar_blocks_company_date '
          'ON calendar_blocks(company_id, block_date)',
      'CREATE INDEX IF NOT EXISTS idx_payment_audit_payment '
          'ON payment_audit(payment_id, happened_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_alert_rules_company_enabled '
          'ON alert_rules(company_id, enabled)',
      'CREATE INDEX IF NOT EXISTS idx_sms_templates_company_code '
          'ON sms_templates(company_id, code)',
      'CREATE INDEX IF NOT EXISTS idx_sms_messages_company_status '
          'ON sms_messages(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_sms_messages_scheduled '
          'ON sms_messages(company_id, scheduled_at)',
      'CREATE INDEX IF NOT EXISTS idx_sms_messages_booking '
          'ON sms_messages(booking_id)',
      'CREATE INDEX IF NOT EXISTS idx_sms_approvals_status '
          'ON sms_approvals(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_notifications_user_created '
          'ON notifications(company_id, user_id, created_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_notifications_unread '
          'ON notifications(company_id, read_at)',
      'CREATE INDEX IF NOT EXISTS idx_notification_jobs_status_scheduled '
          'ON notification_jobs(company_id, status, scheduled_at)',
      'CREATE INDEX IF NOT EXISTS idx_sync_conflicts_status '
          'ON sync_conflicts(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_sync_conflicts_entity '
          'ON sync_conflicts(company_id, entity_type, entity_id)',
      'CREATE INDEX IF NOT EXISTS idx_tombstones_entity_key '
          'ON entity_tombstones(entity_key)',
      'CREATE INDEX IF NOT EXISTS idx_tombstones_remote_required '
          'ON entity_tombstones(company_id, remote_required)',
      'CREATE INDEX IF NOT EXISTS idx_local_meta_workspace_key '
          'ON local_meta(workspace, key)',
      'CREATE INDEX IF NOT EXISTS idx_snapshots_workspace_kind '
          'ON snapshots(workspace, kind, created_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_memberships_company_role '
          'ON company_memberships(company_id, role)',
      'CREATE INDEX IF NOT EXISTS idx_memberships_user '
          'ON company_memberships(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_plans_status_sort '
          'ON plans(status, sort_order)',
      'CREATE INDEX IF NOT EXISTS idx_subscriptions_company_status '
          'ON company_subscriptions(company_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_subscriptions_expires '
          'ON company_subscriptions(expires_at)',
      'CREATE INDEX IF NOT EXISTS idx_wallets_company_default '
          'ON wallets(company_id, is_default)',
      'CREATE INDEX IF NOT EXISTS idx_journal_entries_company_posted '
          'ON journal_entries(company_id, posted_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_journal_entries_source '
          'ON journal_entries(source_type, source_id)',
      'CREATE INDEX IF NOT EXISTS idx_journal_lines_entry '
          'ON journal_lines(entry_id)',
      'CREATE INDEX IF NOT EXISTS idx_journal_lines_account '
          'ON journal_lines(company_id, account_code)',
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
