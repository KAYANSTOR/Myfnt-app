import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mivent/core/database/app_database.dart';
import 'package:mivent/core/database/database_provider.dart';
import 'package:mivent/features/bookings/domain/booking.dart';
import 'package:mivent/features/bookings/providers/booking_providers.dart';
import 'package:mivent/main.dart';

/// ينشئ ProviderScope بـ DB في الذاكرة للاختبارات
Widget _testApp(AppDatabase db) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      monthBookingsProvider.overrideWith((ref) => Stream.value(<Booking>[])),
      monthBookingsMapProvider.overrideWithValue(
        const <DateTime, List<Booking>>{},
      ),
      selectedDayBookingsProvider.overrideWith(
        (ref) => const Stream<List<Booking>>.empty(),
      ),
    ],
    child: const MiventApp(),
  );
}

void main() {
  testWidgets('يعرض التطبيق لوحة التقويم العربية', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await db.close();
    });
    await tester.pumpWidget(_testApp(db));
    await tester.pump();

    expect(find.text('ميفنت'), findsOneWidget);
    expect(find.text('تقويم الحجوزات'), findsOneWidget);
    expect(find.bySemanticsLabel('التقويم'), findsOneWidget);
    expect(find.bySemanticsLabel('الحجوزات'), findsOneWidget);
  });

  testWidgets('ينتقل بين أقسام التطبيق', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await db.close();
    });
    await tester.pumpWidget(_testApp(db));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('الحجوزات'));
    await tester.pumpAndSettle();

    expect(find.text('تابع كل حجوزاتك في مكان واحد'), findsOneWidget);
  });

  testWidgets('زر اليوم يظهر في التقويم', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await db.close();
    });
    await tester.pumpWidget(_testApp(db));
    await tester.pump();

    expect(find.text('اليوم'), findsOneWidget);
  });
}
