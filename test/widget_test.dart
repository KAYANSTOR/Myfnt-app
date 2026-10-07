import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mivent/main.dart';

void main() {
  testWidgets('يعرض التطبيق لوحة التقويم العربية', (tester) async {
    await tester.pumpWidget(const MiventApp());

    expect(find.text('مرحباً بك في ميفنت'), findsOneWidget);
    expect(find.text('تقويم الحجوزات'), findsOneWidget);
    expect(find.text('التقويم'), findsOneWidget);
    expect(find.text('الحجوزات'), findsOneWidget);
  });

  testWidgets('ينتقل بين أقسام التطبيق', (tester) async {
    await tester.pumpWidget(const MiventApp());
    await tester.tap(find.text('الحجوزات'));
    await tester.pumpAndSettle();

    expect(find.text('تابع كل حجوزاتك في مكان واحد'), findsOneWidget);
    expect(find.byIcon(Icons.event_note), findsWidgets);
  });
}
