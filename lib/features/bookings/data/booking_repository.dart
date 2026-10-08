// lib/features/bookings/data/booking_repository.dart
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/helpers/booking_mapper.dart';
import '../../../core/database/helpers/text_normalizer.dart';
import '../../../core/database/helpers/uuid_generator.dart';
import '../../../core/database/tables.dart';
import '../domain/booking.dart';

class BookingRepository {
  BookingRepository({
    required AppDatabase db,
    required String companyId,
    required String actorId,
    required String actorName,
  })  : _db = db,
        _companyId = companyId,
        _actorId = actorId,
        _actorName = actorName;

  final AppDatabase _db;
  final String _companyId;
  final String _actorId;
  final String _actorName;

  Stream<List<Booking>> watchByMonth(int year, int month) {
    return _db.bookingsDao
        .watchByMonth(companyId: _companyId, year: year, month: month)
        .map((rows) => rows.map(BookingMapper.toDomain).toList());
  }

  Stream<List<Booking>> watchByDate(DateTime date) {
    final iso = BookingMapper.dateToIso(date);
    return _db.bookingsDao
        .watchByDate(companyId: _companyId, dateIso: iso)
        .map((rows) => rows.map(BookingMapper.toDomain).toList());
  }

  Stream<List<Booking>> watchAll() {
    return _db.bookingsDao.watchAll().map((rows) => rows
        .where((r) => r.companyId == _companyId)
        .map(BookingMapper.toDomain)
        .toList());
  }

  Future<String> addBooking({
    required String customerName,
    String? customerPhone,
    required DateTime date,
    BookingStatus status = BookingStatus.confirmed,
    String? note,
    double amountTotal = 0,
    double amountPaid = 0,
    String currency = 'YER',
  }) async {
    return _db.transaction(() async {
      final now = DateTime.now().toUtc();

      final customer = await _findOrCreateCustomer(
        name: customerName,
        phone: customerPhone,
      );

      final bookingId = UuidGenerator.random();
      final detailsId = UuidGenerator.random();
      final auditId = UuidGenerator.random();
      final outboxOpId = UuidGenerator.random();

      final amountMinor = (amountTotal * 100).round();
      final paidMinor = (amountPaid * 100).round();

      final bookingNo = await _nextBookingNo();

      final fields = BookingMapper.rowStatusFields(status);

      final searchText = TextNormalizer.buildSearchText([
        bookingNo,
        customerName,
        customerPhone,
      ]);

      await _db.into(_db.bookingsTable).insert(
            BookingsTableCompanion.insert(
              id: bookingId,
              companyId: _companyId,
              bookingNo: bookingNo,
              customerId: customer.id,
              eventDate: BookingMapper.dateToIso(date),
              startsAt: Value(
                  DateTime(date.year, date.month, date.day, 9).toUtc()),
              endsAt: Value(
                  DateTime(date.year, date.month, date.day, 21).toUtc()),
              confirmation: Value(fields.confirmation),
              status: Value(fields.status),
              amountMinor: Value(amountMinor),
              paidMinor: Value(paidMinor),
              currency: Value(currency),
              customerNameSnapshot: Value(customerName),
              customerPhoneSnapshot: Value(customerPhone),
              searchText: searchText,
              createdById: Value(_actorId),
              createdByName: Value(_actorName),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db.into(_db.bookingDetailsTable).insert(
            BookingDetailsTableCompanion.insert(
              id: detailsId,
              bookingId: bookingId,
              companyId: _companyId,
              customerNameSnapshot: customerName,
              customerPhoneSnapshot: Value(customerPhone),
              packageNameSnapshot: 'مناسبة',
              description: Value(note),
              agreedTotalMinor: Value(amountMinor),
              currency: Value(currency),
              updatedAt: now,
            ),
          );

      await _db.into(_db.bookingAuditTable).insert(
            BookingAuditTableCompanion.insert(
              id: auditId,
              companyId: _companyId,
              bookingId: bookingId,
              action: 'create',
              changedFields: const [],
              afterJson: Value({
                'id': bookingId,
                'customerName': customerName,
                'date': BookingMapper.dateToIso(date),
                'amountMinor': amountMinor,
                'paidMinor': paidMinor,
              }),
              happenedAt: now,
            ),
          );

      await _db.into(_db.outboxTable).insert(
            OutboxTableCompanion.insert(
              operationId: outboxOpId,
              companyId: _companyId,
              entityType: 'bookings',
              entityId: bookingId,
              entityKey: '$_companyId|bookings|$bookingId',
              operation: 'create',
              payload: {
                'id': bookingId,
                'bookingNo': bookingNo,
                'customerId': customer.id,
                'customerName': customerName,
                'customerPhone': customerPhone,
                'eventDate': BookingMapper.dateToIso(date),
                'amountMinor': amountMinor,
                'paidMinor': paidMinor,
                'currency': currency,
                'status': fields.status,
                'confirmation': fields.confirmation,
              },
              createdAt: now,
              updatedAt: now,
            ),
          );

      return bookingId;
    });
  }

  Future<void> updateBooking(Booking booking) async {
    await _db.transaction(() async {
      final now = DateTime.now().toUtc();
      final fields = BookingMapper.rowStatusFields(booking.status);
      final auditId = UuidGenerator.random();
      final outboxOpId = UuidGenerator.random();

      final old = await _db.bookingsDao.getById(booking.id);

      await (_db.update(_db.bookingsTable)
            ..where((t) => t.id.equals(booking.id)))
          .write(
        BookingsTableCompanion(
          eventDate: Value(BookingMapper.dateToIso(booking.eventDate)),
          status: Value(fields.status),
          confirmation: Value(fields.confirmation),
          amountMinor: Value(booking.amountMinor),
          paidMinor: Value(booking.paidMinor),
          customerNameSnapshot: Value(booking.customerName),
          customerPhoneSnapshot: Value(booking.customerPhone),
          updatedById: Value(_actorId),
          updatedByName: Value(_actorName),
          updatedAt: Value(now),
        ),
      );

      await _db.into(_db.bookingAuditTable).insert(
            BookingAuditTableCompanion.insert(
              id: auditId,
              companyId: _companyId,
              bookingId: booking.id,
              action: 'update',
              changedFields: const ['eventDate', 'status', 'amountMinor'],
              beforeJson: Value(old == null ? null : {'status': old.status}),
              afterJson: Value({'status': fields.status}),
              happenedAt: now,
            ),
          );

      await _db.into(_db.outboxTable).insert(
            OutboxTableCompanion.insert(
              operationId: outboxOpId,
              companyId: _companyId,
              entityType: 'bookings',
              entityId: booking.id,
              entityKey: '$_companyId|bookings|${booking.id}',
              operation: 'update',
              payload: {
                'id': booking.id,
                'eventDate': BookingMapper.dateToIso(booking.eventDate),
                'amountMinor': booking.amountMinor,
                'paidMinor': booking.paidMinor,
                'status': fields.status,
                'confirmation': fields.confirmation,
              },
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
  }

  Future<void> deleteBooking(String id) async {
    await _db.transaction(() async {
      final now = DateTime.now().toUtc();
      final auditId = UuidGenerator.random();
      final outboxOpId = UuidGenerator.random();

      await (_db.update(_db.bookingsTable)..where((t) => t.id.equals(id)))
          .write(
        BookingsTableCompanion(
          status: const Value('cancelled'),
          updatedAt: Value(now),
        ),
      );

      await _db.into(_db.bookingAuditTable).insert(
            BookingAuditTableCompanion.insert(
              id: auditId,
              companyId: _companyId,
              bookingId: id,
              action: 'cancel',
              changedFields: const ['status'],
              afterJson: const Value({'status': 'cancelled'}),
              happenedAt: now,
            ),
          );

      await _db.into(_db.outboxTable).insert(
            OutboxTableCompanion.insert(
              operationId: outboxOpId,
              companyId: _companyId,
              entityType: 'bookings',
              entityId: id,
              entityKey: '$_companyId|bookings|$id',
              operation: 'delete',
              payload: {'id': id, 'status': 'cancelled'},
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
  }

  Future<CustomerRow> _findOrCreateCustomer({
    required String name,
    String? phone,
  }) async {
    final nameKey = TextNormalizer.normalize(name);
    final phoneKey =
        phone == null ? null : TextNormalizer.normalizePhone(phone);

    List<CustomerRow> matches;
    if (phoneKey != null && phoneKey.isNotEmpty) {
      matches = await _db.customersDao.findDuplicates(
        companyId: _companyId,
        nameKey: nameKey,
        phoneKey: phoneKey,
      );
    } else {
      matches = await _db.customersDao.searchByName(
        companyId: _companyId,
        nameKey: nameKey,
      );
    }

    if (matches.isNotEmpty) return matches.first;

    final now = DateTime.now().toUtc();
    final customerId = UuidGenerator.random();
    final customerNo =
        (await _db.customersDao.nextCustomerNo(_companyId)) ?? '1';
    final searchText = TextNormalizer.buildSearchText([
      customerNo,
      name,
      phone,
    ]);

    await _db.into(_db.customersTable).insert(
          CustomersTableCompanion.insert(
            id: customerId,
            companyId: _companyId,
            customerNo: customerNo,
            name: name,
            phoneE164: Value(phoneKey),
            nameKey: nameKey,
            phoneKey: Value(phoneKey),
            searchText: searchText,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return (await _db.customersDao.getById(customerId))!;
  }

  Future<String> _nextBookingNo() async {
    final rows = await _db.bookingsDao.getAll();
    var max = 0;
    for (final r in rows) {
      if (r.companyId != _companyId) continue;
      final n = int.tryParse(r.bookingNo) ?? 0;
      if (n > max) max = n;
    }
    return (max + 1).toString();
  }
}
