import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfnt/features/bookings/domain/booking.dart';
import 'package:myfnt/features/bookings/presentation/bookings_screen.dart';
import 'package:myfnt/features/bookings/providers/bookings_list_providers.dart';

Booking _booking({
  int id = 1,
  String name = 'أحمد محمد',
  BookingStatus status = BookingStatus.confirmed,
  DateTime? date,
}) {
  return Booking(
    id: id,
    customerName: name,
    date: date ?? DateTime(2026, 10, 8),
    status: status,
    amountTotal: 50000,
    amountPaid: 20000,
  );
}

Widget _wrap(List<Booking> bookings) => ProviderScope(
      overrides: [
        allBookingsProvider.overrideWith((ref) => Stream.value(bookings)),
      ],
      child: const MaterialApp(home: BookingsScreen()),
    );

void main() {
  testWidgets('يعرض عنوان الحجوزات وزر الإضافة', (tester) async {
    await tester.pumpWidget(_wrap(const []));
    await tester.pumpAndSettle();

    expect(find.text('الحجوزات'), findsOneWidget);
    expect(find.text('إضافة حجز'), findsOneWidget);
  });

  testWidgets('يعرض حالة الفراغ عند عدم وجود حجوزات', (tester) async {
    await tester.pumpWidget(_wrap(const []));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد حجوزات'), findsOneWidget);
    expect(find.text('أضف أول حجز للبدء'), findsOneWidget);
  });

  testWidgets('يعرض الحجز الحقيقي من provider', (tester) async {
    await tester.pumpWidget(_wrap([_booking()]));
    await tester.pumpAndSettle();

    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('#001'), findsOneWidget);
  });

  testWidgets('فلتر مؤكد يخفي الحجوزات غير المؤكدة', (tester) async {
    await tester.pumpWidget(_wrap([
      _booking(name: 'مؤكد', status: BookingStatus.confirmed),
      _booking(id: 2, name: 'قيد الانتظار', status: BookingStatus.pending),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('مؤكد'));
    await tester.pumpAndSettle();

    expect(find.text('مؤكد'), findsWidgets);
    expect(find.text('قيد الانتظار'), findsNothing);
  });

  testWidgets('الضغط على حجز يفتح شاشة التفاصيل', (tester) async {
    await tester.pumpWidget(_wrap([_booking()]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('أحمد محمد'));
    await tester.pumpAndSettle();

    expect(find.text('تفاصيل الحجز'), findsOneWidget);
  });
}
