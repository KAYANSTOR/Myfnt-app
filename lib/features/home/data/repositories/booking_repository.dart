import 'package:mivent/features/home/domain/models/booking.dart';

/// واجهة مستودع الحجوزات — جاهزة للاستبدال بمصدر حقيقي لاحقًا.
abstract class BookingRepository {
  Future<List<Booking>> getBookingsForMonth(DateTime month);
  Future<List<Booking>> getBookingsForDate(DateTime date);
  Future<List<Booking>> getAllBookings();
}
