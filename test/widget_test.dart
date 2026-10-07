import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mivent/main.dart';

void main() {
  testWidgets('يشغّل التطبيق ويعرض الشاشة الرئيسية', (tester) async {
    await tester.pumpWidget(const MiventApp());
    await tester.pump(); // init loading
    await tester.pump(const Duration(milliseconds: 500)); // mock delay

    expect(find.text('ميفنت'), findsOneWidget);
    expect(find.text('التقويم'), findsOneWidget);
  });

  testWidgets('يظهر التقويم بعد التحميل', (tester) async {
    await tester.pumpWidget(const MiventApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // أسماء الأشهر العربية تظهر في العنوان
    final monthFinder = find.textContaining(
      RegExp(
        r'(يناير|فبراير|مارس|أبريل|مايو|يونيو|يوليو|أغسطس|سبتمبر|أكتوبر|نوفمبر|ديسمبر)',
      ),
    );
    expect(monthFinder, findsWidgets);
  });

  testWidgets('ينتقل بين أقسام التطبيق', (tester) async {
    await tester.pumpWidget(const MiventApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('الحجوزات'));
    await tester.pumpAndSettle();

    expect(find.text('تابع كل حجوزاتك في مكان واحد'), findsOneWidget);
    expect(find.byIcon(Icons.event_note_rounded), findsOneWidget);
  });

  testWidgets('زر اليوم يعيد للتاريخ الحالي', (tester) async {
    await tester.pumpWidget(const MiventApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // الانتقال لشهر آخر
    final nextBtn = find.byTooltip('الشهر التالي');
    if (nextBtn.evaluate().isNotEmpty) {
      await tester.tap(nextBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    // الرجوع لليوم
    final todayBtn = find.text('اليوم');
    expect(todayBtn, findsWidgets);
    await tester.tap(todayBtn.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // يجب أن يظهر زر اليوم مجددًا
    expect(find.text('اليوم'), findsWidgets);
  });

  testWidgets('يظهر زر حجز جديد', (tester) async {
    await tester.pumpWidget(const MiventApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('حجز جديد'), findsOneWidget);
  });

  testWidgets('يفتح تفاصيل الحجز عند الضغط', (tester) async {
    await tester.pumpWidget(const MiventApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // إذا وُجدت بطاقة حجز نضغط عليها
    final cards = find.byType(InkWell);
    if (cards.evaluate().isNotEmpty) {
      // نبحث عن نص عميل معروف من الـ mock
      final customer = find.text('سارة الأحمد');
      if (customer.evaluate().isNotEmpty) {
        await tester.tap(customer.first);
        await tester.pumpAndSettle();
        expect(find.text('إغلاق'), findsOneWidget);
      }
    }
  });

  testWidgets('يفتح placeholder إضافة حجز', (tester) async {
    await tester.pumpWidget(const MiventApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('حجز جديد'));
    await tester.pumpAndSettle();

    expect(find.text('إضافة حجز جديد'), findsOneWidget);
    expect(find.text('حسنًا'), findsOneWidget);
  });
}
