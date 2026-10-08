// lib/core/database/daos/bookings_dao.dart
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'bookings_dao.g.dart';

@DriftAccessor(tables: [BookingsTable, BookingDetailsTable])
class BookingsDao extends DatabaseAccessor<AppDatabase> with _$BookingsDaoMixin {
  BookingsDao(super.db);

  // ═══════════════════════════════════════════════════════════════
  // قراءة
  // ═══════════════════════════════════════════════════════════════

  /// جميع الحجوزات لشهر معين (للتقويم).
  Stream<List<BookingRow>> watchByMonth({
    required String companyId,
    required int year,
    required int month,
  }) {
    final start = DateTime.utc(year, month, 1);
    final end = DateTime.utc(year, month + 1, 1);
    return (select(bookingsTable)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.eventDate.isBiggerOrEqualValue(start) &
              t.eventDate.isSmallerThanValue(end) &
              t.status.isNotValue('cancelled'))
          ..orderBy([(t) => OrderingTerm.asc(t.startsAt)]))
        .watch();
  }

  /// حجوزات يوم معين.
  Stream<List<BookingRow>> watchByDate({
    required String companyId,
    required DateTime date,
  }) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(bookingsTable)
          ..where((t) =>
              t.companyId.equals(companyId) &
              t.eventDate.isBiggerOrEqualValue(start) &
              t.eventDate.isSmallerThanValue(end) &
              t.status.isNotValue('cancelled'))
          ..orderBy([(t) => OrderingTerm.asc(t.startsAt)]))
        .watch();
  }

  /// قراءة مرة واحدة (للاختبارات).
  Future<List<BookingRow>> getAll() {
    return (select(bookingsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
        .get();
  }

  /// حجز واحد.
  Future<BookingRow?> getById(String id) {
    return (select(bookingsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// البحث بالاسم/الهاتف/رقم الحجز.
  /// يستخدم `searchText` المُفهرس.
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

  // ═══════════════════════════════════════════════════════════════
  // كتابة
  // ═══════════════════════════════════════════════════════════════

  /// إدراج حجز — يُستخدَم من الـ Repository داخل Transaction.
  Future<int> insert(BookingsTableCompanion entry) {
    return into(bookingsTable).insert(entry);
  }

  /// تعديل حجز.
  Future<bool> updateBooking(BookingsTableCompanion entry) {
    return update(bookingsTable).replace(entry);
  }

  /// حذف ناعم: يُغيّر الحالة إلى `cancelled` بدلاً من حذف الصف.
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

  // ═══════════════════════════════════════════════════════════════
  // التفاصيل
  // ═══════════════════════════════════════════════════════════════

  /// تفاصيل حجز — يُستخدَم في المعاينة.
  Future<BookingDetailRow?> getDetails(String bookingId) {
    return (select(bookingDetailsTable)
          ..where((t) => t.bookingId.equals(bookingId)))
        .getSingleOrNull();
  }

  /// إدراج التفاصيل.
  Future<int> insertDetails(BookingDetailsTableCompanion entry) {
    return into(bookingDetailsTable).insert(entry);
  }

  /// تعديل التفاصيل.
  Future<bool> updateDetails(BookingDetailsTableCompanion entry) {
    return update(bookingDetailsTable).replace(entry);
  }
}
