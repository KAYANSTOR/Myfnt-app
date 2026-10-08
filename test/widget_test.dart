import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfnt/core/database/app_database.dart';
import 'package:myfnt/core/database/database_provider.dart';
import 'package:myfnt/features/bookings/domain/booking.dart';
import 'package:myfnt/features/bookings/providers/booking_providers.dart';
import 'package:myfnt/main.dart';

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
    child: const MyfntApp(),
  );
}

void main() {
  testWidgets('يعرض التطبيق الشريط العلوي والتنقل', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await db.close();
    });
    await tester.pumpWidget(_testApp(db));
    await tester.pump();

    expect(find.text('Myfnt'), findsOneWidget);
    expect(find.text('الحجوزات'), findsWidgets);
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
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

    await tester.tap(find.byIcon(Icons.event_note_outlined));
    await tester.pumpAndSettle();

    expect(find.text('تابع كل حجوزاتك في مكان واحد'), findsOneWidget);
  });

  testWidgets('فلتر اليوم يظهر في الشاشة', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await db.close();
    });
    await tester.pumpWidget(_testApp(db));
    await tester.pump();

    expect(find.text('اليوم'), findsWidgets);
  });
}
