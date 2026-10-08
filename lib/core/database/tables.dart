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
  TextColumn get beforeJson => text().named('before_json').map(const NullableJsonMapConverter()).nullable()();
  TextColumn get afterJson => text().named('after_json').map(const NullableJsonMapConverter()).nullable()();
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

// ═══════════════════════════════════════════════════════════════════
// Phase 5 — الكتالوج والتدقيق المالي
// ═══════════════════════════════════════════════════════════════════

@DataClassName('BookingPackageRow')
class BookingPackagesTable extends Table {
  @override
  String get tableName => 'booking_packages';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get regularPriceMinor =>
      integer().named('regular_price_minor').withDefault(const Constant(0))();
  IntColumn get seasonPriceMinor =>
      integer().named('season_price_minor').withDefault(const Constant(0))();
  IntColumn get defaultDepositMinor =>
      integer().named('default_deposit_minor').withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  BoolColumn get allowDoubleBooking => boolean()
      .named('allow_double_booking')
      .withDefault(const Constant(false))();
  BoolColumn get allowDiscount =>
      boolean().named('allow_discount').withDefault(const Constant(true))();
  BoolColumn get builtInLocal =>
      boolean().named('built_in_local').withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get packageVersion =>
      integer().named('package_version').withDefault(const Constant(1))();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  IntColumn get serverVersion =>
      integer().named('server_version').withDefault(const Constant(0))();
  BoolColumn get serverAdopted =>
      boolean().named('server_adopted').withDefault(const Constant(false))();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'UNIQUE(company_id, name)',
      ];
}

@DataClassName('BookingPackageVersionRow')
class BookingPackageVersionsTable extends Table {
  @override
  String get tableName => 'booking_package_versions';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get packageId => text().named('package_id')();
  IntColumn get version => integer()();
  TextColumn get snapshot => text().map(const JsonMapConverter())();
  TextColumn get reason => text().nullable()();
  TextColumn get effectiveFrom =>
      text().named('effective_from').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (package_id) REFERENCES booking_packages(id) ON DELETE CASCADE',
        'UNIQUE(package_id, version)',
      ];
}

@DataClassName('BookingTypeRow')
class BookingTypesTable extends Table {
  @override
  String get tableName => 'booking_types';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id').nullable()();
  TextColumn get code => text()();
  TextColumn get nameAr => text().named('name_ar')();
  TextColumn get nameEn => text().named('name_en').nullable()();
  TextColumn get colorHex => text().named('color_hex').nullable()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();
  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => ['UNIQUE(company_id, code)'];
}

@DataClassName('CalendarBlockRow')
class CalendarBlocksTable extends Table {
  @override
  String get tableName => 'calendar_blocks';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get blockKind => text().named('block_kind')();
  TextColumn get blockDate => text().named('block_date').nullable()();
  TextColumn get startDate => text().named('start_date').nullable()();
  TextColumn get endDate => text().named('end_date').nullable()();
  TextColumn get weekdays => text()
      .named('weekdays')
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get colorHex => text().named('color_hex').nullable()();
  IntColumn get serverVersion =>
      integer().named('server_version').withDefault(const Constant(0))();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

@DataClassName('PaymentAuditRow')
class PaymentAuditTable extends Table {
  @override
  String get tableName => 'payment_audit';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get paymentId => text().named('payment_id')();
  TextColumn get action => text()();
  TextColumn get reason => text().nullable()();
  TextColumn get beforeJson => text()
      .named('before_json')
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get afterJson => text()
      .named('after_json')
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get actorId => text().named('actor_id').nullable()();
  TextColumn get actorName => text().named('actor_name').nullable()();
  TextColumn get happenedAt =>
      text().named('happened_at').map(const UtcDateTimeConverter())();
  TextColumn get source =>
      text().withDefault(const Constant('offline_app'))();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// Phase 6 — الاتصالات والإشعارات
// ═══════════════════════════════════════════════════════════════════

@DataClassName('AlertRuleRow')
class AlertRulesTable extends Table {
  @override
  String get tableName => 'alert_rules';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get eventCode =>
      text().named('event_code').withDefault(const Constant('event.approaching'))();
  TextColumn get direction => text().withDefault(const Constant('before'))();
  IntColumn get intervalValue =>
      integer().named('interval_value').withDefault(const Constant(1))();
  TextColumn get intervalUnit =>
      text().named('interval_unit').withDefault(const Constant('days'))();
  TextColumn get recipientKind =>
      text().named('recipient_kind').withDefault(const Constant('staff'))();
  TextColumn get channels => text().map(const JsonListConverter())();
  TextColumn get priority => text().withDefault(const Constant('normal'))();
  TextColumn get clientTemplate =>
      text().named('client_template').nullable()();
  TextColumn get staffTemplate => text().named('staff_template').nullable()();
  BoolColumn get enabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  IntColumn get serverVersion =>
      integer().named('server_version').withDefault(const Constant(0))();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

@DataClassName('SmsTemplateRow')
class SmsTemplatesTable extends Table {
  @override
  String get tableName => 'sms_templates';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get code => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get body => text()();
  TextColumn get variables => text()
      .named('variables')
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get category =>
      text().withDefault(const Constant('notification'))();
  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'UNIQUE(company_id, code)',
      ];
}

@DataClassName('SmsMessageRow')
class SmsMessagesTable extends Table {
  @override
  String get tableName => 'sms_messages';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get idempotencyKey =>
      text().named('idempotency_key').unique()();
  TextColumn get eventCode =>
      text().named('event_code').withDefault(const Constant('custom'))();
  TextColumn get bookingId => text().named('booking_id').nullable()();
  TextColumn get paymentId => text().named('payment_id').nullable()();
  TextColumn get customerId => text().named('customer_id').nullable()();
  TextColumn get ruleId => text().named('rule_id').nullable()();
  TextColumn get recipientPhone => text().named('recipient_phone')();
  TextColumn get recipientKind =>
      text().named('recipient_kind').withDefault(const Constant('client'))();
  TextColumn get recipientName =>
      text().named('recipient_name').nullable()();
  TextColumn get message => text()();
  TextColumn get status => text().withDefault(const Constant('queued'))();
  BoolColumn get requiresApproval => boolean()
      .named('requires_approval')
      .withDefault(const Constant(false))();
  TextColumn get approvalStatus => text()
      .named('approval_status')
      .withDefault(const Constant('not_required'))();
  TextColumn get approvedAt => text()
      .named('approved_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  TextColumn get approvedBy => text().named('approved_by').nullable()();
  TextColumn get scheduledAt =>
      text().named('scheduled_at').map(const UtcDateTimeConverter())();
  TextColumn get sentAt => text()
      .named('sent_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();
  TextColumn get providerId => text().named('provider_id').nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  BoolColumn get isUrgent =>
      boolean().named('is_urgent').withDefault(const Constant(false))();
  TextColumn get createdById => text().named('created_by_id').nullable()();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL',
        'FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL',
      ];
}

@DataClassName('SmsApprovalRow')
class SmsApprovalsTable extends Table {
  @override
  String get tableName => 'sms_approvals';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get messageId => text().named('message_id')();
  TextColumn get ruleId => text().named('rule_id').nullable()();
  TextColumn get bookingId => text().named('booking_id').nullable()();
  TextColumn get requestedById =>
      text().named('requested_by_id').nullable()();
  TextColumn get scheduledAt =>
      text().named('scheduled_at').map(const UtcDateTimeConverter())();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get approvedAt => text()
      .named('approved_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  TextColumn get approvedById =>
      text().named('approved_by_id').nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get idempotencyKey =>
      text().named('idempotency_key').nullable()();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'FOREIGN KEY (message_id) REFERENCES sms_messages(id) ON DELETE CASCADE',
      ];
}

@DataClassName('NotificationRow')
class NotificationsTable extends Table {
  @override
  String get tableName => 'notifications';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get type => text()();
  TextColumn get bookingId => text().named('booking_id').nullable()();
  TextColumn get paymentId => text().named('payment_id').nullable()();
  TextColumn get customerId => text().named('customer_id').nullable()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  TextColumn get tone => text().withDefault(const Constant('primary'))();
  TextColumn get icon => text().withDefault(const Constant('fa-bell'))();
  TextColumn get title => text()();
  TextColumn get body => text().nullable()();
  TextColumn get targetKind => text().named('target_kind').nullable()();
  TextColumn get targetId => text().named('target_id').nullable()();
  TextColumn get dedupeKey => text().named('dedupe_key').nullable()();
  TextColumn get scheduledAt => text()
      .named('scheduled_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  BoolColumn get isUrgent =>
      boolean().named('is_urgent').withDefault(const Constant(false))();
  TextColumn get actorId => text().named('actor_id').nullable()();
  TextColumn get actorName => text().named('actor_name').nullable()();
  TextColumn get readAt => text()
      .named('read_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  TextColumn get resolvedAt => text()
      .named('resolved_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  TextColumn get expiresAt => text()
      .named('expires_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

@DataClassName('NotificationJobRow')
class NotificationJobsTable extends Table {
  @override
  String get tableName => 'notification_jobs';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get kind => text()();
  TextColumn get payload => text().map(const JsonMapConverter())();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get scheduledAt =>
      text().named('scheduled_at').map(const UtcDateTimeConverter())();
  TextColumn get nextAttemptAt => text()
      .named('next_attempt_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get completedAt => text()
      .named('completed_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// Phase 7 — بنية المزامنة
// ═══════════════════════════════════════════════════════════════════

@DataClassName('SyncConflictRow')
class SyncConflictsTable extends Table {
  @override
  String get tableName => 'sync_conflicts';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get entityKey => text().named('entity_key')();
  TextColumn get operation => text()();
  TextColumn get localCommandId =>
      text().named('local_command_id').nullable()();
  IntColumn get baseVersion =>
      integer().named('base_version').withDefault(const Constant(0))();
  IntColumn get remoteVersion =>
      integer().named('remote_version').nullable()();
  TextColumn get localPayload =>
      text().named('local_payload').map(const JsonMapConverter())();
  TextColumn get remotePayload => text()
      .named('remote_payload')
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get localSnapshot => text()
      .named('local_snapshot')
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get source => text().nullable()();
  TextColumn get error => text().nullable()();
  TextColumn get resolvedById => text().named('resolved_by_id').nullable()();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  TextColumn get resolvedAt => text()
      .named('resolved_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

@DataClassName('EntityTombstoneRow')
class EntityTombstonesTable extends Table {
  @override
  String get tableName => 'entity_tombstones';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get entityKey => text().named('entity_key')();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get operation => text()();
  TextColumn get reason => text().nullable()();
  TextColumn get snapshot => text()
      .nullable()
      .map(const NullableJsonMapConverter())();
  IntColumn get baseVersion =>
      integer().named('base_version').withDefault(const Constant(0))();
  BoolColumn get remoteRequired => boolean()
      .named('remote_required')
      .withDefault(const Constant(true))();
  BoolColumn get adoptionSettled => boolean()
      .named('adoption_settled')
      .withDefault(const Constant(false))();
  TextColumn get adoptionId => text().named('adoption_id').nullable()();
  TextColumn get deletedAt =>
      text().named('deleted_at').map(const UtcDateTimeConverter())();
  TextColumn get syncedAt => text()
      .named('synced_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  TextColumn get adoptionSettledAt => text()
      .named('adoption_settled_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'UNIQUE(entity_key)',
      ];
}

@DataClassName('LocalMetaRow')
class LocalMetaTable extends Table {
  @override
  String get tableName => 'local_meta';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id').nullable()();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get workspace => text()();
  TextColumn get key => text()();
  TextColumn get value => text()
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  TextColumn get expiresAt => text()
      .named('expires_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => ['UNIQUE(workspace, key)'];
}

@DataClassName('SnapshotRow')
class SnapshotsTable extends Table {
  @override
  String get tableName => 'snapshots';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get userId => text().named('user_id')();
  TextColumn get workspace => text()();
  TextColumn get kind => text().withDefault(const Constant('emergency'))();
  IntColumn get schemaVersion =>
      integer().named('schema_version').withDefault(const Constant(4))();
  TextColumn get payload => text().map(const JsonMapConverter())();
  TextColumn get sha256 => text().withDefault(const Constant(''))();
  IntColumn get sizeBytes =>
      integer().named('size_bytes').withDefault(const Constant(0))();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// Phase 8 — العضويات والاشتراكات والمحاسبة
// ═══════════════════════════════════════════════════════════════════

@DataClassName('CompanyMembershipRow')
class CompanyMembershipsTable extends Table {
  @override
  String get tableName => 'company_memberships';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get userId => text().named('user_id')();
  TextColumn get role => text().withDefault(const Constant('manager'))();
  TextColumn get permissions => text()
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get invitedById => text().named('invited_by_id').nullable()();
  TextColumn get joinedAt =>
      text().named('joined_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE',
        'UNIQUE(company_id, user_id)',
      ];
}

@DataClassName('PlanRow')
class PlansTable extends Table {
  @override
  String get tableName => 'plans';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get code => text().unique()();
  TextColumn get nameAr => text().named('name_ar')();
  TextColumn get nameEn => text().named('name_en').nullable()();
  TextColumn get tagline => text().nullable()();
  IntColumn get monthlyPrice =>
      integer().named('monthly_price').nullable()();
  IntColumn get annualPrice => integer().named('annual_price').nullable()();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  TextColumn get limits => text().map(const JsonMapConverter())();
  TextColumn get features => text()
      .nullable()
      .map(const NullableJsonMapConverter())();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompanySubscriptionRow')
class CompanySubscriptionsTable extends Table {
  @override
  String get tableName => 'company_subscriptions';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get legacyId => text().named('legacy_id').nullable()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get planCode => text().named('plan_code')();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get billingCycle =>
      text().named('billing_cycle').withDefault(const Constant('annual'))();
  IntColumn get paidAmountMinor =>
      integer().named('paid_amount_minor').withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  TextColumn get paymentMethod => text().named('payment_method').nullable()();
  TextColumn get startsAt =>
      text().named('starts_at').map(const UtcDateTimeConverter())();
  TextColumn get expiresAt => text()
      .named('expires_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  TextColumn get cancelledAt => text()
      .named('cancelled_at')
      .nullable()
      .map(const NullableUtcDateTimeConverter())();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

@DataClassName('WalletRow')
class WalletsTable extends Table {
  @override
  String get tableName => 'wallets';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get kind => text().withDefault(const Constant('cash'))();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  IntColumn get cachedBalanceMinor => integer()
      .named('cached_balance_minor')
      .withDefault(const Constant(0))();
  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  BoolColumn get balanceIsDerived => boolean()
      .named('balance_is_derived')
      .withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

@DataClassName('JournalEntryRow')
class JournalEntriesTable extends Table {
  @override
  String get tableName => 'journal_entries';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get entryNo => text().named('entry_no')();
  TextColumn get kind => text()();
  TextColumn get description => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  TextColumn get sourceType => text().named('source_type').nullable()();
  TextColumn get sourceId => text().named('source_id').nullable()();
  IntColumn get totalDebitMinor => integer()
      .named('total_debit_minor')
      .withDefault(const Constant(0))();
  IntColumn get totalCreditMinor => integer()
      .named('total_credit_minor')
      .withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  TextColumn get createdById => text().named('created_by_id').nullable()();
  TextColumn get createdByName => text().named('created_by_name').nullable()();
  TextColumn get postedAt =>
      text().named('posted_at').map(const UtcDateTimeConverter())();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'UNIQUE(company_id, entry_no)',
      ];
}

@DataClassName('JournalLineRow')
class JournalLinesTable extends Table {
  @override
  String get tableName => 'journal_lines';
  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get entryId => text().named('entry_id')();
  TextColumn get side => text()();
  TextColumn get accountCode =>
      text().named('account_code').withDefault(const Constant('cash'))();
  TextColumn get accountName => text().named('account_name').nullable()();
  IntColumn get amountMinor => integer().named('amount_minor')();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  TextColumn get refType => text().named('ref_type').nullable()();
  TextColumn get refId => text().named('ref_id').nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 31. كتالوج الميزات المركزي
// ═══════════════════════════════════════════════════════════════════

@DataClassName('FeatureCatalogRow')
class FeatureCatalogTable extends Table {
  @override
  String get tableName => 'feature_catalog';

  TextColumn get id => text().map(const UuidConverter())();

  /// كود الميزة الثابت (bookings_limit, sms_monthly_limit, ...).
  /// لا يتغير أبداً.
  TextColumn get code => text().unique()();

  TextColumn get nameAr => text().named('name_ar')();
  TextColumn get nameEn => text().named('name_en').nullable()();

  /// المجموعة: bookings | users | messages | backup | ...
  TextColumn get groupCode => text().named('group_code')();

  /// boolean | limit | quota | storage | config
  TextColumn get featureType => text().named('feature_type')();

  /// current | monthly | yearly | subscription
  TextColumn get defaultPeriodType =>
      text().named('default_period_type').nullable()();

  /// booking | user | message | phone | byte | backup | ...
  TextColumn get unit => text().nullable()();

  /// switch | row_count | usage_counter | storage | config
  TextColumn get countStrategy =>
      text().named('count_strategy').withDefault(const Constant('switch'))();

  TextColumn get configSchemaJson =>
      text().named('config_schema_json')
          .map(const NullableJsonMapConverter())
          .nullable()();

  TextColumn get description => text().nullable()();

  /// active | hidden | deprecated
  TextColumn get status =>
      text().withDefault(const Constant('active'))();

  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();

  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════
// 32. قيم الميزات في الخطط
// ═══════════════════════════════════════════════════════════════════

@DataClassName('PlanFeatureRow')
class PlanFeaturesTable extends Table {
  @override
  String get tableName => 'plan_features';

  TextColumn get id => text().map(const UuidConverter())();

  /// كود الخطة (BASIC | PLUS | SUPER | ULTRA).
  TextColumn get planCode => text().named('plan_code')();

  /// كود الميزة (من feature_catalog).
  TextColumn get featureCode => text().named('feature_code')();

  BoolColumn get enabled =>
      boolean().withDefault(const Constant(true))();

  /// NULL = غير محدود (إذا كانت الميزة مفعلة).
  IntColumn get limitValue =>
      integer().named('limit_value').nullable()();

  /// تجاوز فترة الميزة (اختياري).
  TextColumn get periodType =>
      text().named('period_type').nullable()();

  TextColumn get configJson =>
      text().named('config_json')
          .map(const NullableJsonMapConverter())
          .nullable()();

  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(plan_code, feature_code)',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 33. استثناءات ميزات الشركات (Overrides)
// ═══════════════════════════════════════════════════════════════════

@DataClassName('CompanyFeatureOverrideRow')
class CompanyFeatureOverridesTable extends Table {
  @override
  String get tableName => 'company_feature_overrides';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();

  TextColumn get featureCode => text().named('feature_code')();

  /// NULL = قيمة الخطة.
  BoolColumn get enabledOverride =>
      boolean().named('enabled_override').nullable()();

  /// NULL = حد الخطة.
  IntColumn get limitOverride =>
      integer().named('limit_override').nullable()();

  TextColumn get periodTypeOverride =>
      text().named('period_type_override').nullable()();

  TextColumn get configOverrideJson =>
      text().named('config_override_json')
          .map(const NullableJsonMapConverter())
          .nullable()();

  TextColumn get startsAt =>
      text().named('starts_at').nullable().map(const NullableUtcDateTimeConverter())();

  TextColumn get expiresAt =>
      text().named('expires_at').nullable().map(const NullableUtcDateTimeConverter())();

  /// active | revoked | expired
  TextColumn get status =>
      text().withDefault(const Constant('active'))();

  TextColumn get reason => text().nullable()();

  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 34. أرقام الرسائل لكل شركة
// ═══════════════════════════════════════════════════════════════════

@DataClassName('CompanyMessageNumberRow')
class CompanyMessageNumbersTable extends Table {
  @override
  String get tableName => 'company_message_numbers';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();

  /// sms | whatsapp
  TextColumn get channel => text()();

  TextColumn get phoneE164 => text().named('phone_e164')();
  TextColumn get label => text().nullable()();

  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();

  /// active | inactive
  TextColumn get status =>
      text().withDefault(const Constant('active'))();

  IntColumn get serverVersion =>
      integer().named('server_version').withDefault(const Constant(0))();
  BoolColumn get serverAdopted =>
      boolean().named('server_adopted').withDefault(const Constant(false))();

  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'UNIQUE(company_id, channel, phone_e164)',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 35. قوالب الإشعارات المحلية
// ═══════════════════════════════════════════════════════════════════

@DataClassName('NotificationTemplateRow')
class NotificationTemplatesTable extends Table {
  @override
  String get tableName => 'notification_templates';

  TextColumn get id => text().map(const UuidConverter())();

  /// NULL = قالب افتراضي للنظام.
  TextColumn get companyId => text().named('company_id').nullable()();

  /// كود فريد (booking_tomorrow, payment_created, ...).
  TextColumn get code => text()();

  TextColumn get name => text()();
  TextColumn get titleTemplate => text().named('title_template')();
  TextColumn get bodyTemplate => text().named('body_template')();

  /// bookings | payments | customers | system
  TextColumn get sourceType => text().named('source_type')();

  /// date_relative | rule | data_state
  TextColumn get triggerType => text().named('trigger_type')();

  /// low | normal | high | critical
  TextColumn get priority =>
      text().withDefault(const Constant('normal'))();

  BoolColumn get enabled =>
      boolean().withDefault(const Constant(true))();

  TextColumn get configJson =>
      text().named('config_json')
          .map(const NullableJsonMapConverter())
          .nullable()();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(company_id, code)',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 36. قوالب التنبيهات الذكية
// ═══════════════════════════════════════════════════════════════════

@DataClassName('AlertTemplateRow')
class AlertTemplatesTable extends Table {
  @override
  String get tableName => 'alert_templates';

  TextColumn get id => text().map(const UuidConverter())();

  /// NULL = قالب افتراضي.
  TextColumn get companyId => text().named('company_id').nullable()();

  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get titleTemplate => text().named('title_template')();
  TextColumn get bodyTemplate => text().named('body_template')();
  TextColumn get sourceType => text().named('source_type')();

  /// low | normal | high | critical
  TextColumn get defaultPriority =>
      text().named('default_priority').withDefault(const Constant('normal'))();

  TextColumn get configJson =>
      text().named('config_json')
          .map(const NullableJsonMapConverter())
          .nullable()();

  BoolColumn get enabled =>
      boolean().withDefault(const Constant(true))();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(company_id, code)',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 37. المرفقات (ميتاداتا فقط — الملف في Storage)
// ═══════════════════════════════════════════════════════════════════

@DataClassName('AttachmentRow')
class AttachmentsTable extends Table {
  @override
  String get tableName => 'attachments';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();

  /// booking | customer | payment | request | ...
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();

  TextColumn get fileName => text().named('file_name')();
  TextColumn get mimeType => text().named('mime_type')();
  IntColumn get sizeBytes =>
      integer().named('size_bytes').withDefault(const Constant(0))();

  /// local | s3 | drive
  TextColumn get storageDriver =>
      text().named('storage_driver').withDefault(const Constant('local'))();

  TextColumn get objectKey => text().named('object_key')();
  TextColumn get checksum => text().nullable()();

  TextColumn get createdByUserId =>
      text().named('created_by_user_id').nullable()();

  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get deletedAt =>
      text().named('deleted_at').nullable().map(const NullableUtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 38. عدادات الاستخدام (cache محلي — server authoritative)
// ═══════════════════════════════════════════════════════════════════

@DataClassName('UsageCounterRow')
class UsageCountersTable extends Table {
  @override
  String get tableName => 'usage_counters';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get companyId => text().named('company_id')();

  /// كود الميزة (sms_monthly_limit, exports_monthly_limit, ...)
  TextColumn get metricCode => text().named('metric_code')();

  /// YYYY-MM | YYYY | lifetime
  TextColumn get periodKey => text().named('period_key')();

  IntColumn get usedCount =>
      integer().named('used_count').withDefault(const Constant(0))();

  /// Snapshot للحد وقت الفترة (لتجنب تغيير الحد وسط الفترة).
  IntColumn get limitSnapshot =>
      integer().named('limit_snapshot').nullable()();

  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
        'UNIQUE(company_id, metric_code, period_key)',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 39. محفظة الرسائل (cache — server authoritative)
// ═══════════════════════════════════════════════════════════════════

@DataClassName('SmsWalletRow')
class SmsWalletsTable extends Table {
  @override
  String get tableName => 'sms_wallets';

  TextColumn get id => text().map(const UuidConverter())();

  /// محفظة واحدة لكل شركة.
  TextColumn get companyId => text().named('company_id').unique()();

  /// الرصيد بالـ Minor Units (server authoritative).
  IntColumn get balanceMinor =>
      integer().named('balance_minor').withDefault(const Constant(0))();

  TextColumn get currency =>
      text().withDefault(const Constant('YER'))();

  /// active | suspended
  TextColumn get status =>
      text().withDefault(const Constant('active'))();

  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 40. إعلانات الإدارة المركزية (cache)
// ═══════════════════════════════════════════════════════════════════

@DataClassName('AdminAnnouncementRow')
class AdminAnnouncementsTable extends Table {
  @override
  String get tableName => 'admin_announcements';

  TextColumn get id => text().map(const UuidConverter())();

  TextColumn get title => text()();
  TextColumn get body => text()();

  /// all | company | plan
  TextColumn get targetType =>
      text().named('target_type').withDefault(const Constant('all'))();

  TextColumn get targetId => text().named('target_id').nullable()();

  /// low | normal | high
  TextColumn get priority =>
      text().withDefault(const Constant('normal'))();

  TextColumn get startsAt =>
      text().named('starts_at').nullable().map(const NullableUtcDateTimeConverter())();

  TextColumn get expiresAt =>
      text().named('expires_at').nullable().map(const NullableUtcDateTimeConverter())();

  /// active | expired | hidden
  TextColumn get status =>
      text().withDefault(const Constant('active'))();

  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════
// 41. قراءة الإعلانات (local tracking)
// ═══════════════════════════════════════════════════════════════════

@DataClassName('AdminAnnouncementReadRow')
class AdminAnnouncementReadsTable extends Table {
  @override
  String get tableName => 'admin_announcement_reads';

  TextColumn get id => text().map(const UuidConverter())();
  TextColumn get announcementId => text().named('announcement_id')();
  TextColumn get userId => text().named('user_id')();

  TextColumn get readAt =>
      text().named('read_at').nullable().map(const NullableUtcDateTimeConverter())();
  TextColumn get dismissedAt =>
      text().named('dismissed_at').nullable().map(const NullableUtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(announcement_id, user_id)',
      ];
}

// ═══════════════════════════════════════════════════════════════════
// 42. بوابات الرسائل (metadata فقط — لا secrets)
// ═══════════════════════════════════════════════════════════════════

@DataClassName('MessageGatewayRow')
class MessageGatewaysTable extends Table {
  @override
  String get tableName => 'message_gateways';

  TextColumn get id => text().map(const UuidConverter())();

  /// NULL = بوابة المنصة الافتراضية.
  TextColumn get companyId => text().named('company_id').nullable()();

  TextColumn get provider => text()();

  /// sms | whatsapp
  TextColumn get channel => text()();

  TextColumn get name => text()();

  /// ملاحظة أمنية: لا نخزن credentials محلياً.
  /// هذا الحقل يُستخدم فقط للتحقق من وجود البوابة على الخادم.
  BoolColumn get hasCredentials =>
      boolean().named('has_credentials').withDefault(const Constant(false))();

  /// إعدادات غير حساسة (endpoint, sender_id, ...).
  TextColumn get configJson =>
      text().named('config_json')
          .map(const NullableJsonMapConverter())
          .nullable()();

  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();

  IntColumn get priority =>
      integer().withDefault(const Constant(100))();

  /// active | inactive | error
  TextColumn get status =>
      text().withDefault(const Constant('active'))();

  TextColumn get lastSuccessAt =>
      text().named('last_success_at').nullable().map(const NullableUtcDateTimeConverter())();
  TextColumn get lastErrorAt =>
      text().named('last_error_at').nullable().map(const NullableUtcDateTimeConverter())();

  TextColumn get createdAt =>
      text().named('created_at').map(const UtcDateTimeConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const UtcDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE',
      ];
}
