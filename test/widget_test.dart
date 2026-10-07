import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mivent/core/database/app_database.dart';
import 'package:mivent/core/database/database_provider.dart';
import 'package:mivent/main.dart';

/// ينشئ ProviderScope بـ DB في الذاكرة للاختبارات
Widget _testApp() {
  final db = AppDatabase(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const MiventApp(),
  );
}

void main() {
  testWidgets('يعرض التطبيق لوحة التقويم العربية', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();

    expect(find.text('مرحباً بك في ميفنت'), findsOneWidget);
    expect(find.text('تقويم الحجوزات'), findsOneWidget);
    expect(find.text('التقويم'), findsOneWidget);
    expect(find.text('الحجوزات'), findsOneWidget);
  });

  testWidgets('ينتقل بين أقسام التطبيق', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();

    await tester.tap(find.text('الحجوزات'));
    await tester.pumpAndSettle();

    expect(find.text('تابع كل حجوزاتك في مكان واحد'), findsOneWidget);
  });

  testWidgets('زر اليوم يظهر في التقويم', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();

    expect(find.text('اليوم'), findsOneWidget);
  });
}
