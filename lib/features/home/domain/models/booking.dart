/// حالة الحجز المعروضة في الشاشة الرئيسية.
enum BookingStatus { confirmed, provisional }

extension BookingStatusX on BookingStatus {
  String get labelAr {
    switch (this) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.provisional:
        return 'مؤقت';
    }
  }

  bool get isConfirmed => this == BookingStatus.confirmed;
}

/// نموذج حجز بسيط للشاشة الرئيسية.
class Booking {
  const Booking({
    required this.id,
    required this.customerName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.packageName,
    required this.status,
    required this.amount,
    required this.paid,
  });

  final String id;
  final String customerName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String packageName;
  final BookingStatus status;
  final double amount;
  final double paid;

  double get remaining => (amount - paid).clamp(0, double.infinity);

  bool isOnDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }

  bool isInMonth(DateTime month) {
    return date.year == month.year && date.month == month.month;
  }
}

/// حالات تحميل الشاشة الرئيسية.
enum HomeLoadState { loading, ready, error, offline, syncing }
