// lib/core/database/daos/bookings_dao.dart
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'bookings_dao.g.dart';

@DriftAccessor(tables: [BookingsTable, BookingDetailsTable])
class BookingsDao extends DatabaseAccessor<AppDatabase>
    with _$BookingsDaoMixin {
  BookingsDao(super.db);

  Stream<List<BookingRow>> watchAll() {
    return (select(bookingsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
        .watch();
  }

  Stream<List<BookingRow>> watchByMonth({
    required String companyId,
    required int year,
    required int month,
  }) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final m = month.toString().padLeft(2, '0');
    final from = '$year-$m-01';
    final to = '$year-$m-${lastDay.toString().padLeft(2, '0')}';

    return (select(bookingsTable)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.eventDate.isBiggerOrEqualValue(from) &
              t.eventDate.isSmallerOrEqualValue(to) &
              t.status.isNotIn(['cancelled', 'archived']))
          ..orderBy([(t) => OrderingTerm.asc(t.eventDate)]))
        .watch();
  }

  Stream<List<BookingRow>> watchByDate({
    required String companyId,
    required String dateIso,
  }) {
    return (select(bookingsTable)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.eventDate.equals(dateIso) &
              t.status.isNotIn(['cancelled', 'archived']))
          ..orderBy([(t) => OrderingTerm.asc(t.startsAt)]))
        .watch();
  }

  Future<List<BookingRow>> getAll() {
    return (select(bookingsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
        .get();
  }

  Future<BookingRow?> getById(String id) {
    return (select(bookingsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<BookingRow>> search({
    required String companyId,
    required String query,
    int limit = 30,
  }) {
    final normalized = query.toLowerCase().trim();
    return (select(bookingsTable)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.searchText.like('%$normalized%'))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .get();
  }

  Future<int> insert(BookingsTableCompanion entry) {
    return into(bookingsTable).insert(entry);
  }

  Future<bool> updateBooking(BookingsTableCompanion entry) {
    return update(bookingsTable).replace(entry);
  }

  Future<int> softDelete({
    required String id,
    required String reason,
  }) {
    return (update(bookingsTable)..where((t) => t.id.equals(id))).write(
      BookingsTableCompanion(
        status: const Value('cancelled'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<BookingDetailRow?> getDetails(String bookingId) {
    return (select(bookingDetailsTable)
          ..where((t) => t.bookingId.equals(bookingId)))
        .getSingleOrNull();
  }

  Future<int> insertDetails(BookingDetailsTableCompanion entry) {
    return into(bookingDetailsTable).insert(entry);
  }

  Future<bool> updateDetails(BookingDetailsTableCompanion entry) {
    return update(bookingDetailsTable).replace(entry);
  }

  /// أقصى رقم حجز حالي — بسرعة O(1) عبر SQL.
  /// booking_no مخزَّن كنص، لذلك نحتاج CAST إلى INTEGER.
  Future<int> maxBookingNo(String companyId) async {
    final rows = await customSelect(
      'SELECT MAX(CAST(booking_no AS INTEGER)) AS max_no '
      'FROM bookings WHERE company_id = ?',
      variables: [Variable<String>(companyId)],
      readsFrom: {bookingsTable},
    ).getSingleOrNull();

    final value = rows?.read<int?>('max_no');
    return value ?? 0;
  }
}
