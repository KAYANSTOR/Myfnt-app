import 'package:flutter/foundation.dart';

/// حالة الحجز
enum BookingStatus {
  confirmed, // مؤكد
  partial, // جزئي (دفعة مقدمة فقط)
  pending, // قيد الانتظار
  cancelled, // ملغى
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
    }
  }
}

/// نموذج الحجز في طبقة Domain — نظيف تماماً بدون أي تبعيات خارجية
@immutable
class Booking {
  const Booking({
    required this.id,
    required this.customerName,
    required this.date,
    required this.status,
    this.note,
    this.amountTotal = 0,
    this.amountPaid = 0,
    this.createdAt,
  });

  final int id;
  final String customerName;
  final DateTime date;
  final BookingStatus status;
  final String? note;
  final double amountTotal;
  final double amountPaid;
  final DateTime? createdAt;

  double get amountRemaining => amountTotal - amountPaid;
  bool get isFullyPaid => amountRemaining <= 0;

  /// تاريخ اليوم فقط بدون وقت — للمقارنة في التقويم
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  Booking copyWith({
    int? id,
    String? customerName,
    DateTime? date,
    BookingStatus? status,
    String? note,
    double? amountTotal,
    double? amountPaid,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      amountTotal: amountTotal ?? this.amountTotal,
      amountPaid: amountPaid ?? this.amountPaid,
      createdAt: createdAt ?? this.createdAt,
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
      'Booking(id: $id, customer: $customerName, date: $date, status: $status)';
}
