import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/booking.dart';

/// Repository للحجوزات — الطبقة الوحيدة التي تعرف تفاصيل SQL
/// Controllers تتعامل مع هذه الطبقة فقط
class BookingRepository {
  const BookingRepository(this._dao);

  final BookingsDao _dao;

  // ── Streams تفاعلية ──────────────────────────────

  /// Stream يتحدث تلقائياً عند أي تغيير في حجوزات الشهر
  Stream<List<Booking>> watchByMonth(int year, int month) => _dao
      .watchByMonth(year, month)
      .map((rows) => rows.map(_rowToBooking).toList());

  /// Stream يتحدث عند أي تغيير في حجوزات يوم محدد
  Stream<List<Booking>> watchByDate(DateTime date) =>
      _dao.watchByDate(date).map((rows) => rows.map(_rowToBooking).toList());

  /// Stream بجميع الحجوزات
  Stream<List<Booking>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_rowToBooking).toList());

  /// بحث نصي في الاسم أو رقم الحجز دون تعديل مخطط قاعدة البيانات.
  Future<List<Booking>> searchBookings({required String query}) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const <Booking>[];

    final bookings = await watchAll().first;
    return bookings
        .where(
          (booking) =>
              booking.customerName.toLowerCase().contains(normalized) ||
              booking.id.toString().contains(normalized),
        )
        .toList();
  }

  // ── عمليات CRUD ──────────────────────────────────

  Future<int> addBooking({
    required String customerName,
    required DateTime date,
    BookingStatus status = BookingStatus.confirmed,
    String? note,
    double amountTotal = 0,
    double amountPaid = 0,
  }) => _dao.insert(
    BookingsTableCompanion.insert(
      customerName: customerName,
      date: date,
      status: Value(status.name),
      note: Value(note),
      amountTotal: Value(amountTotal),
      amountPaid: Value(amountPaid),
    ),
  );

  Future<bool> updateBooking(Booking booking) => _dao.update_(
    BookingsTableCompanion(
      id: Value(booking.id),
      customerName: Value(booking.customerName),
      date: Value(booking.date),
      status: Value(booking.status.name),
      note: Value(booking.note),
      amountTotal: Value(booking.amountTotal),
      amountPaid: Value(booking.amountPaid),
    ),
  );

  Future<void> deleteBooking(int id) => _dao.delete_(id);

  // ── تحويل من DB Row إلى Domain Model ─────────────

  Booking _rowToBooking(BookingsTableData row) => Booking(
    id: row.id,
    customerName: row.customerName,
    date: row.date,
    status: _parseStatus(row.status),
    note: row.note,
    amountTotal: row.amountTotal,
    amountPaid: row.amountPaid,
    createdAt: row.createdAt,
  );

  BookingStatus _parseStatus(String raw) {
    return BookingStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => BookingStatus.confirmed,
    );
  }
}
