// lib/features/bookings/providers/booking_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/company/company_providers.dart';
import '../../../core/database/database_provider.dart';
import '../data/booking_repository.dart';
import '../domain/booking.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(currentCompanyIdProvider);
  final userId = ref.watch(currentUserIdProvider);
  return BookingRepository(
    db: db,
    companyId: companyId,
    actorId: userId,
    actorName: 'المستخدم المحلي',
  );
});

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

final selectedMonthProvider = NotifierProvider<_SelectedMonth, DateTime>(
  _SelectedMonth.new,
);

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

final monthBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.watchByMonth(month.year, month.month);
});

final monthBookingsMapProvider = Provider<Map<DateTime, List<Booking>>>((ref) {
  final asyncBookings = ref.watch(monthBookingsProvider);
  return asyncBookings.when<Map<DateTime, List<Booking>>>(
    data: (bookings) {
      final map = <DateTime, List<Booking>>{};
      for (final b in bookings) {
        final key = b.dateOnly;
        map.putIfAbsent(key, () => <Booking>[]).add(b);
      }
      return map;
    },
    loading: () => <DateTime, List<Booking>>{},
    error: (_, __) => <DateTime, List<Booking>>{},
  );
});

final selectedDayBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final day = ref.watch(selectedDayProvider);
  if (day == null) return const Stream.empty();
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.watchByDate(day);
});

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

  final totalDays = DateTime(month.year, month.month + 1, 0).day;

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

class BookingController {
  const BookingController(this._repo);
  final BookingRepository _repo;

  Future<String> addBooking({
    required String customerName,
    String? customerPhone,
    required DateTime date,
    BookingStatus status = BookingStatus.confirmed,
    String? note,
    double amountTotal = 0,
    double amountPaid = 0,
    String currency = 'YER',
    String? packageId,
    String? packageName,
    int? packagePriceMinor,
    int? depositMinor,
  }) =>
      _repo.addBooking(
        customerName: customerName,
        customerPhone: customerPhone,
        date: date,
        status: status,
        note: note,
        amountTotal: amountTotal,
        amountPaid: amountPaid,
        currency: currency,
        packageId: packageId,
        packageName: packageName,
        packagePriceMinor: packagePriceMinor,
        depositMinor: depositMinor,
      );

  Future<void> updateBooking(Booking booking) => _repo.updateBooking(booking);

  Future<void> deleteBooking(String id) => _repo.deleteBooking(id);
}

final bookingControllerProvider = Provider<BookingController>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return BookingController(repo);
});
