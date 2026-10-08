// lib/features/payments/data/payment_repository.dart
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/enums/payment_direction.dart';
import '../../../core/database/helpers/text_normalizer.dart';
import '../../../core/database/helpers/uuid_generator.dart';
import '../../../core/database/tables.dart';

class PaymentRepository {
  PaymentRepository({
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

  Stream<List<PaymentRow>> watchByBooking(String bookingId) =>
      _db.paymentsDao.watchByBooking(
        companyId: _companyId,
        bookingId: bookingId,
      );

  Stream<List<PaymentRow>> watchAll() =>
      _db.paymentsDao.watchAll(companyId: _companyId);

  Future<String> addPayment({
    required String bookingId,
    required String customerId,
    required int amountMinor,
    PaymentDirection direction = PaymentDirection.incoming,
    String method = 'cash',
    String? reference,
    String? memo,
    String? tag,
    String currency = 'YER',
  }) async {
    return _db.transaction(() async {
      final now = DateTime.now().toUtc();

      final paymentId = UuidGenerator.random();
      final receiptNo =
          (await _db.paymentsDao.nextReceiptNo(_companyId)) ?? '1';
      final outboxOpId = UuidGenerator.random();

      final booking = await _db.bookingsDao.getById(bookingId);

      await _db.into(_db.paymentsTable).insert(
            PaymentsTableCompanion.insert(
              id: paymentId,
              companyId: _companyId,
              bookingId: Value(bookingId),
              customerId: Value(customerId),
              receiptNo: receiptNo,
              direction: Value(direction.value),
              amountMinor: amountMinor,
              currency: Value(currency),
              paymentMethod: Value(method),
              externalReference: Value(reference),
              memo: Value(memo),
              tag: Value(tag),
              postedAt: now,
              status: const Value('posted'),
              bookingNoSnapshot: Value(booking?.bookingNo),
              customerNameSnapshot: Value(booking?.customerNameSnapshot),
              searchText: Value(TextNormalizer.buildSearchText([
                receiptNo,
                reference,
                memo,
                tag,
                booking?.bookingNo,
                booking?.customerNameSnapshot,
              ])),
              createdById: Value(_actorId),
              createdByName: Value(_actorName),
              createdAt: now,
              updatedAt: now,
            ),
          );

      if (booking != null) {
        final delta = direction == PaymentDirection.incoming
            ? amountMinor
            : -amountMinor;
        final newPaid = (booking.paidMinor + delta).clamp(0, 1 << 62);

        await (_db.update(_db.bookingsTable)
              ..where((t) => t.id.equals(bookingId)))
            .write(
          BookingsTableCompanion(
            paidMinor: Value(newPaid),
            updatedAt: Value(now),
          ),
        );
      }

      await _db.into(_db.outboxTable).insert(
            OutboxTableCompanion.insert(
              operationId: outboxOpId,
              companyId: _companyId,
              entityType: 'payments',
              entityId: paymentId,
              entityKey: '$_companyId|payments|$paymentId',
              operation: 'create',
              payload: {
                'id': paymentId,
                'bookingId': bookingId,
                'customerId': customerId,
                'receiptNo': receiptNo,
                'amountMinor': amountMinor,
                'direction': direction.value,
                'method': method,
                'postedAt': now.toIso8601String(),
              },
              createdAt: now,
              updatedAt: now,
            ),
          );

      return paymentId;
    });
  }
}
