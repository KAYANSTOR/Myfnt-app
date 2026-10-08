// lib/features/bookings/domain/booking.dart
import 'package:flutter/foundation.dart';

enum BookingStatus {
  confirmed,
  partial,
  pending,
  cancelled,
  completed,
  archived,
}

extension BookingStatusLabel on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.partial:
        return 'جزئي';
      case BookingStatus.pending:
        return 'قيد الانتظار';
      case BookingStatus.cancelled:
        return 'ملغى';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.archived:
        return 'مؤرشف';
    }
  }
}

@immutable
class Booking {
  const Booking({
    required this.id,
    required this.customerId,
    required this.bookingNo,
    required this.customerName,
    required this.eventDate,
    required this.status,
    this.customerPhone,
    this.startsAt,
    this.endsAt,
    this.note,
    this.amountMinor = 0,
    this.paidMinor = 0,
    this.currency = 'YER',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String customerId;
  final String bookingNo;
  final String customerName;
  final String? customerPhone;
  final DateTime eventDate;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final BookingStatus status;
  final String? note;
  final int amountMinor;
  final int paidMinor;
  final String currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get amountRemainingMinor =>
      (amountMinor - paidMinor).clamp(0, amountMinor);

  bool get isFullyPaid => amountRemainingMinor <= 0;

  double get amountTotal => amountMinor / 100.0;
  double get amountPaid => paidMinor / 100.0;
  double get amountRemaining => amountRemainingMinor / 100.0;

  DateTime get dateOnly =>
      DateTime(eventDate.year, eventDate.month, eventDate.day);

  DateTime get date => eventDate;

  Booking copyWith({
    String? id,
    String? customerId,
    String? bookingNo,
    String? customerName,
    String? customerPhone,
    DateTime? eventDate,
    DateTime? startsAt,
    DateTime? endsAt,
    BookingStatus? status,
    String? note,
    int? amountMinor,
    int? paidMinor,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      bookingNo: bookingNo ?? this.bookingNo,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      eventDate: eventDate ?? this.eventDate,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      status: status ?? this.status,
      note: note ?? this.note,
      amountMinor: amountMinor ?? this.amountMinor,
      paidMinor: paidMinor ?? this.paidMinor,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Booking(id: $id, customer: $customerName, date: $eventDate, status: $status)';
}
