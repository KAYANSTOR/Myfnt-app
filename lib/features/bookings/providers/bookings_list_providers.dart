import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/booking.dart';
import 'booking_providers.dart';

enum BookingsFilter { all, today, upcoming, confirmed, pending, partial, cancelled }

extension BookingsFilterX on BookingsFilter {
  String get label => switch (this) {
        BookingsFilter.all => 'الكل',
        BookingsFilter.today => 'اليوم',
        BookingsFilter.upcoming => 'القادمة',
        BookingsFilter.confirmed => 'مؤكد',
        BookingsFilter.pending => 'قيد الانتظار',
        BookingsFilter.partial => 'جزئي',
        BookingsFilter.cancelled => 'ملغى',
      };
}

final bookingsSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

final bookingsFilterProvider =
    StateProvider.autoDispose<BookingsFilter>((ref) => BookingsFilter.all);

final allBookingsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.watchAll();
});

final searchBookingsProvider =
    FutureProvider.autoDispose.family<List<Booking>, String>((ref, query) {
  final q = query.trim();
  if (q.isEmpty) return Future.value(const <Booking>[]);
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.searchBookings(query: q);
});

final filteredBookingsProvider =
    Provider.autoDispose<AsyncValue<List<Booking>>>((ref) {
  final query = ref.watch(bookingsSearchQueryProvider);
  final filter = ref.watch(bookingsFilterProvider);
  final source = query.trim().isEmpty
      ? ref.watch(allBookingsProvider)
      : ref.watch(searchBookingsProvider(query));

  return source.whenData((list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Iterable<Booking> filtered = list;

    filtered = switch (filter) {
      BookingsFilter.all => filtered,
      BookingsFilter.today => filtered.where((b) => b.dateOnly == today),
      BookingsFilter.upcoming => filtered.where((b) => !b.dateOnly.isBefore(today)),
      BookingsFilter.confirmed =>
        filtered.where((b) => b.status == BookingStatus.confirmed),
      BookingsFilter.pending =>
        filtered.where((b) => b.status == BookingStatus.pending),
      BookingsFilter.partial =>
        filtered.where((b) => b.status == BookingStatus.partial),
      BookingsFilter.cancelled =>
        filtered.where((b) => b.status == BookingStatus.cancelled),
    };

    return filtered.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  });
});
