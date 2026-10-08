// lib/core/database/helpers/booking_mapper.dart
import 'package:drift/drift.dart';

import '../../features/bookings/domain/booking.dart';
import '../tables.dart';

class BookingMapper {
  BookingMapper._();

  static Booking toDomain(BookingRow row) {
    return Booking(
      id: row.id,
      customerId: row.customerId,
      bookingNo: row.bookingNo,
      customerName: row.customerNameSnapshot ?? 'بدون اسم',
      customerPhone: row.customerPhoneSnapshot,
      eventDate: DateTime.parse(row.eventDate),
      startsAt: row.startsAt,
      endsAt: row.endsAt,
      status: _statusFromRow(row),
      note: null,
      amountMinor: row.amountMinor,
      paidMinor: row.paidMinor,
      currency: row.currency,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static ({String status, String confirmation}) rowStatusFields(
    BookingStatus status,
  ) {
    switch (status) {
      case BookingStatus.cancelled:
        return (status: 'cancelled', confirmation: 'confirmed');
      case BookingStatus.completed:
        return (status: 'completed', confirmation: 'confirmed');
      case BookingStatus.archived:
        return (status: 'archived', confirmation: 'confirmed');
      case BookingStatus.pending:
        return (status: 'active', confirmation: 'temporary');
      case BookingStatus.partial:
      case BookingStatus.confirmed:
        return (status: 'active', confirmation: 'confirmed');
    }
  }

  static BookingStatus _statusFromRow(BookingRow row) {
    switch (row.status) {
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'archived':
        return BookingStatus.archived;
    }
    if (row.confirmation == 'temporary') {
      return BookingStatus.pending;
    }
    if (row.amountMinor > 0 && row.paidMinor < row.amountMinor) {
      return BookingStatus.partial;
    }
    return BookingStatus.confirmed;
  }

  static String dateToIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }
}
