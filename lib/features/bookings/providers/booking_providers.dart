import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/booking_repository.dart';
import '../domain/booking.dart';

// ── Repository ────────────────────────────────────────────

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final dao = ref.watch(bookingsDaoProvider);
  return BookingRepository(dao);
});

// ── حالة التقويم: الشهر المحدد ────────────────────────────

class _SelectedMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void next() => state = DateTime(state.year, state.month + 1);
  void previous() => state = DateTime(state.year, state.month - 1);
  void goToToday() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month);
  }
}

final selectedMonthProvider =
    NotifierProvider<_SelectedMonth, DateTime>(_SelectedMonth.new);

// ── حالة اليوم المحدد في التقويم ──────────────────────────

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

// ── Streams تفاعلية للبيانات ──────────────────────────────

/// حجوزات الشهر الحالي — يتحدث تلقائياً عند تغيير الشهر أو البيانات
final monthBookingsProvider =
    StreamProvider<List<Booking>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.watchByMonth(month.year, month.month);
});

/// خريطة تاريخ → قائمة حجوزات — للتقويم (أداء أفضل من البحث في كل مرة)
final monthBookingsMapProvider =
    Provider<Map<DateTime, List<Booking>>>((ref) {
  final asyncBookings = ref.watch(monthBookingsProvider);
  return asyncBookings.when(
    data: (bookings) {
      final map = <DateTime, List<Booking>>{};
      for (final b in bookings) {
        final key = b.dateOnly;
        map.putIfAbsent(key, () => []).add(b);
      }
      return map;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// حجوزات اليوم المحدد
final selectedDayBookingsProvider =
    StreamProvider<List<Booking>>((ref) {
  final day = ref.watch(selectedDayProvider);
  if (day == null) return const Stream.empty();
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.watchByDate(day);
});

// ── إحصائيات الشهر ────────────────────────────────────────

class MonthSummary {
  const MonthSummary({
    required this.totalDays,
    required this.bookedDays,
    required this.partialDays,
  });

  final int totalDays;
  final int bookedDays;
  final int partialDays;

  int get availableDays => totalDays - bookedDays - partialDays;
}

final monthSummaryProvider = Provider<MonthSummary>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final map = ref.watch(monthBookingsMapProvider);

  final totalDays =
      DateTime(month.year, month.month + 1, 0).day;

  var bookedDays = 0;
  var partialDays = 0;

  for (final bookings in map.values) {
    final hasConfirmed =
        bookings.any((b) => b.status == BookingStatus.confirmed);
    final hasPartial =
        bookings.any((b) => b.status == BookingStatus.partial);

    if (hasConfirmed) {
      bookedDays++;
    } else if (hasPartial) {
      partialDays++;
    }
  }

  return MonthSummary(
    totalDays: totalDays,
    bookedDays: bookedDays,
    partialDays: partialDays,
  );
});

// ── Controller للعمليات ───────────────────────────────────

class BookingController {
  const BookingController(this._repo);
  final BookingRepository _repo;

  Future<void> addBooking({
    required String customerName,
    required DateTime date,
    BookingStatus status = BookingStatus.confirmed,
    String? note,
    double amountTotal = 0,
    double amountPaid = 0,
  }) =>
      _repo.addBooking(
        customerName: customerName,
        date: date,
        status: status,
        note: note,
        amountTotal: amountTotal,
        amountPaid: amountPaid,
      );

  Future<void> updateBooking(Booking booking) => _repo.updateBooking(booking);

  Future<void> deleteBooking(int id) => _repo.deleteBooking(id);
}

final bookingControllerProvider = Provider<BookingController>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return BookingController(repo);
});
