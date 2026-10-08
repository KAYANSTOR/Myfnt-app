import 'package:flutter_test/flutter_test.dart';
import 'package:myfnt/features/bookings/domain/booking.dart';

Booking _booking({
  String id = 'booking-1',
  DateTime? eventDate,
  int amountMinor = 50000,
  int paidMinor = 20000,
}) {
  return Booking(
    id: id,
    customerId: 'customer-1',
    bookingNo: '1',
    customerName: 'أحمد محمد',
    eventDate: eventDate ?? DateTime(2026, 10, 15, 10, 0),
    status: BookingStatus.confirmed,
    amountMinor: amountMinor,
    paidMinor: paidMinor,
  );
}

void main() {
  group('Booking model —', () {
    final booking = _booking();

    test('يحسب المبلغ المتبقي بشكل صحيح', () {
      expect(booking.amountRemaining, 300);
    });

    test('يكتشف الدفع الكامل بشكل صحيح', () {
      expect(booking.isFullyPaid, false);
      final paid = booking.copyWith(paidMinor: booking.amountMinor);
      expect(paid.isFullyPaid, true);
    });

    test('dateOnly يُرجع التاريخ بدون وقت', () {
      final dateOnly = booking.dateOnly;
      expect(dateOnly.hour, 0);
      expect(dateOnly.minute, 0);
      expect(dateOnly.second, 0);
      expect(dateOnly.day, 15);
      expect(dateOnly.month, 10);
    });

    test('copyWith يحتفظ بالقيم غير المُغيَّرة', () {
      final updated = booking.copyWith(customerName: 'علي أحمد');
      expect(updated.id, booking.id);
      expect(updated.customerName, 'علي أحمد');
      expect(updated.status, booking.status);
      expect(updated.amountMinor, booking.amountMinor);
    });

    test('المساواة تعتمد على ID فقط', () {
      final same = booking.copyWith(customerName: 'اسم مختلف');
      expect(booking == same, true);
      final different = booking.copyWith(id: 'booking-2');
      expect(booking == different, false);
    });

    test('BookingStatus.label يُرجع النص العربي الصحيح', () {
      expect(BookingStatus.confirmed.label, 'مؤكد');
      expect(BookingStatus.partial.label, 'جزئي');
      expect(BookingStatus.pending.label, 'قيد الانتظار');
      expect(BookingStatus.cancelled.label, 'ملغى');
    });
  });

  group('Booking تواريخ حقيقية —', () {
    test('يعمل مع أشهر مختلفة', () {
      final jan = _booking(eventDate: DateTime(2026, 1, 1));
      final dec = _booking(id: 'booking-2', eventDate: DateTime(2026, 12, 31));
      expect(jan.date.month, 1);
      expect(dec.date.month, 12);
    });

    test('يعمل مع سنوات مختلفة', () {
      final b2025 = _booking(eventDate: DateTime(2025, 6, 15));
      final b2027 = b2025.copyWith(eventDate: DateTime(2027, 6, 15));
      expect(b2025.date.year, 2025);
      expect(b2027.date.year, 2027);
    });
  });
}
