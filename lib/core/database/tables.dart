// lib/core/database/tables.dart
//
// جداول قاعدة بيانات Myfnt: UUID، minor units، UTC، ومزامنة آمنة.

import 'package:drift/drift.dart';

import 'converters/json_converter.dart';
import 'converters/utc_datetime_converter.dart';
import 'converters/uuid_converter.dart';

@DataClassName('CompanyRow')
class CompaniesTable extends Table {
  @override
  String get tableName => 'companies';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phone1 => text().named('phone_1').nullable()();
  TextColumn get phone2 => text().named('phone_2').nullable()();
  TextColumn get logoObjectKey => text().named('logo_object_key').nullable()();
  TextColumn get source => text().withDefault(const Constant('offline_app'))();
  IntColumn get serverVersion => integer().named('server_version').withDefault(const Constant(0))();
  BoolColumn get serverAdopted => boolean().named('server_adopted').withDefault(const Constant(false))();
  TextColumn get createdAt => text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserRow')
class UsersTable extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phoneE164 => text().named('phone_e164').nullable()();
  BoolColumn get noPasswordExported => boolean().named('no_password_exported').withDefault(const Constant(true))();
  TextColumn get createdAt => text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompanySettingsRow')
class CompanySettingsTable extends Table {
  @override
  String get tableName => 'company_settings';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get languageTag => text().named('language_tag').withDefault(const Constant('ar'))();
  TextColumn get calendarKind => text().named('calendar_kind').withDefault(const Constant('gregorian'))();
  TextColumn get preferredNotificationTime => text().named('preferred_notification_time').withDefault(const Constant('09:00'))();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  TextColumn get syncMode => text().named('sync_mode').withDefault(const Constant('manual'))();
  TextColumn get timezoneName => text().named('timezone_name').withDefault(const Constant('Asia/Aden'))();
  TextColumn get depositPolicy => text().named('deposit_policy').withDefault(const Constant('optional'))();
  BoolColumn get allowBookingOverpayment => boolean().named('allow_booking_overpayment').withDefault(const Constant(false))();
  BoolColumn get allowReceiptOverRemaining => boolean().named('allow_receipt_over_remaining').withDefault(const Constant(false))();
  TextColumn get requiredFields => text().named('required_fields').map(const JsonMapConverter())();
  BoolColumn get seasonEnabled => boolean().named('season_enabled').withDefault(const Constant(true))();
  TextColumn get seasonName => text().named('season_name').withDefault(const Constant('موسم'))();
  TextColumn get seasonStartMmdd => text().named('season_start_mmdd').withDefault(const Constant('03-10'))();
  TextColumn get seasonEndMmdd => text().named('season_end_mmdd').withDefault(const Constant('09-30'))();
  TextColumn get reminderDays => text().named('reminder_days').map(const JsonListConverter())();
  TextColumn get updatedAt => text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'UNIQUE(company_id)',
      ];
}

@DataClassName('CustomerRow')
class CustomersTable extends Table {
  @override
  String get tableName => 'customers';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get customerNo => text().named('customer_no')();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phoneE164 => text().named('phone_e164').nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get nameKey => text().named('name_key')();
  TextColumn get phoneKey => text().named('phone_key').nullable()();
  TextColumn get searchText => text().named('search_text')();
  BoolColumn get intentionalDuplicate => boolean().named('intentional_duplicate').withDefault(const Constant(false))();
  IntColumn get serverVersion => integer().named('server_version').withDefault(const Constant(0))();
  BoolColumn get serverAdopted => boolean().named('server_adopted').withDefault(const Constant(false))();
  TextColumn get createdAt => text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'UNIQUE(company_id, customer_no)',
      ];
}

@DataClassName('BookingRow')
class BookingsTable extends Table {
  @override
  String get tableName => 'bookings';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get bookingNo => text().named('booking_no')();
  TextColumn get customerId => text().named('customer_id')();
  TextColumn get eventDate => text().named('event_date')();
  TextColumn get startsAt => text().named('starts_at').map(const NullableUtcDateTimeConverter()).nullable()();
  TextColumn get endsAt => text().named('ends_at').map(const NullableUtcDateTimeConverter()).nullable()();
  TextColumn get confirmation => text().withDefault(const Constant('confirmed'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get temporaryExpiresAt => text().named('temporary_expires_at').map(const NullableUtcDateTimeConverter()).nullable()();
  IntColumn get amountMinor => integer().named('amount_minor').withDefault(const Constant(0))();
  IntColumn get paidMinor => integer().named('paid_minor').withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  TextColumn get customerNameSnapshot => text().named('customer_name_snapshot').nullable()();
  TextColumn get customerPhoneSnapshot => text().named('customer_phone_snapshot').nullable()();
  TextColumn get packageNameSnapshot => text().named('package_name_snapshot').nullable()();
  TextColumn get searchText => text().named('search_text')();
  IntColumn get serverVersion => integer().named('server_version').withDefault(const Constant(0))();
  BoolColumn get serverAdopted => boolean().named('server_adopted').withDefault(const Constant(false))();
  TextColumn get createdById => text().named('created_by_id').nullable()();
  TextColumn get createdByName => text().named('created_by_name').nullable()();
  TextColumn get updatedById => text().named('updated_by_id').nullable()();
  TextColumn get updatedByName => text().named('updated_by_name').nullable()();
  TextColumn get createdAt => text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT',
      ];
}

@DataClassName('BookingDetailRow')
class BookingDetailsTable extends Table {
  @override
  String get tableName => 'booking_details';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get bookingId => text().named('booking_id')();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get customerNameSnapshot => text().named('customer_name_snapshot')();
  TextColumn get customerPhoneSnapshot => text().named('customer_phone_snapshot').nullable()();
  TextColumn get addressSnapshot => text().named('address_snapshot').nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get packageId => text().named('package_id').nullable()();
  TextColumn get packageNameSnapshot => text().named('package_name_snapshot')();
  IntColumn get packagePriceMinorSnapshot => integer().named('package_price_minor_snapshot').withDefault(const Constant(0))();
  IntColumn get depositMinorSnapshot => integer().named('deposit_minor_snapshot').withDefault(const Constant(0))();
  IntColumn get discountMinor => integer().named('discount_minor').withDefault(const Constant(0))();
  IntColumn get surchargeMinor => integer().named('surcharge_minor').withDefault(const Constant(0))();
  TextColumn get adjustmentReason => text().named('adjustment_reason').nullable()();
  IntColumn get agreedTotalMinor => integer().named('agreed_total_minor').withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  TextColumn get updatedAt => text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE',
        'UNIQUE(booking_id)',
      ];
}

@DataClassName('PaymentRow')
class PaymentsTable extends Table {
  @override
  String get tableName => 'payments';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get bookingId => text().named('booking_id').nullable()();
  TextColumn get customerId => text().named('customer_id').nullable()();
  TextColumn get receiptNo => text().named('receipt_no')();
  TextColumn get movementNo => text().named('movement_no').nullable()();
  TextColumn get direction => text().withDefault(const Constant('in'))();
  IntColumn get amountMinor => integer().named('amount_minor')();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  TextColumn get paymentMethod => text().named('payment_method').withDefault(const Constant('cash'))();
  TextColumn get externalReference => text().named('external_reference').nullable()();
  TextColumn get memo => text().nullable()();
  TextColumn get tag => text().nullable()();
  TextColumn get postedAt => text().named('posted_at').map(const UtcDateTimeConverter())();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  TextColumn get reversalReason => text().named('reversal_reason').nullable()();
  TextColumn get bookingNoSnapshot => text().named('booking_no_snapshot').nullable()();
  TextColumn get customerNameSnapshot => text().named('customer_name_snapshot').nullable()();
  TextColumn get searchText => text().named('search_text')();
  IntColumn get serverVersion => integer().named('server_version').withDefault(const Constant(0))();
  TextColumn get createdById => text().named('created_by_id').nullable()();
  TextColumn get createdByName => text().named('created_by_name').nullable()();
  TextColumn get editedById => text().named('edited_by_id').nullable()();
  TextColumn get editedByName => text().named('edited_by_name').nullable()();
  TextColumn get createdAt => text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL',
        'FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL',
      ];
}

@DataClassName('BookingAuditRow')
class BookingAuditTable extends Table {
  @override
  String get tableName => 'booking_audit';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get bookingId => text().named('booking_id')();
  TextColumn get action => text()();
  TextColumn get changedFields => text().named('changed_fields').map(const JsonListConverter())();
  TextColumn get reason => text().nullable()();
  TextColumn get beforeJson => text().named('before_json').map(const NullableJsonMapConverter())();
  TextColumn get afterJson => text().named('after_json').map(const NullableJsonMapConverter())();
  TextColumn get happenedAt => text().named('happened_at').map(const UtcDateTimeConverter())();
  TextColumn get source => text().withDefault(const Constant('offline_app'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE',
      ];
}

@DataClassName('OutboxRow')
class OutboxTable extends Table {
  @override
  String get tableName => 'outbox';

  IntColumn get seq => integer().autoIncrement()();
  TextColumn get operationId => text().named('operation_id').unique()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get entityKey => text().named('entity_key')();
  TextColumn get operation => text()();
  TextColumn get payload => text().map(const JsonMapConverter())();
  IntColumn get baseVersion => integer().named('base_version').withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();
  IntColumn get lastHttpStatus => integer().named('last_http_status').nullable()();
  TextColumn get nextAttemptAt => text().named('next_attempt_at').map(const NullableUtcDateTimeConverter()).nullable()();
  TextColumn get leaseUntil => text().named('lease_until').map(const NullableUtcDateTimeConverter()).nullable()();
  BoolColumn get retryable => boolean().withDefault(const Constant(true))();
  TextColumn get latestLocalPayload => text().named('latest_local_payload').map(const NullableJsonMapConverter()).nullable()();
  TextColumn get createdAt => text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt => text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {seq};
}
