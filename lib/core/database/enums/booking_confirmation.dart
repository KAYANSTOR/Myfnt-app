// lib/core/database/enums/booking_confirmation.dart

/// تأكيد الحجز — منفصل عن BookingStatus.
///
/// الفرق:
///   - BookingConfirmation: هل الحجز مؤكد أم مؤقت؟
///   - BookingStatus: هل هو نشط، ملغى، مكتمل، مؤرشف؟
enum BookingConfirmation {
  confirmed('confirmed', 'مؤكد'),
  temporary('temporary', 'مؤقت');

  const BookingConfirmation(this.value, this.label);
  final String value;
  final String label;

  static BookingConfirmation fromValue(String v) =>
      BookingConfirmation.values.firstWhere(
        (e) => e.value == v,
        orElse: () => BookingConfirmation.confirmed,
      );
}
