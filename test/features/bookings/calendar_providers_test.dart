import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mivent/features/bookings/providers/booking_providers.dart';

void main() {
  group('selectedMonthProvider —', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('القيمة الابتدائية هي الشهر الحالي', () {
      final now = DateTime.now();
      final month = container.read(selectedMonthProvider);
      expect(month.year, now.year);
      expect(month.month, now.month);
      expect(month.day, 1);
    });

    test('next() ينتقل للشهر التالي', () {
      final before = container.read(selectedMonthProvider);
      container.read(selectedMonthProvider.notifier).next();
      final after = container.read(selectedMonthProvider);

      final expectedMonth = before.month == 12 ? 1 : before.month + 1;
      expect(after.month, expectedMonth);
    });

    test('previous() يعود للشهر السابق', () {
      container.read(selectedMonthProvider.notifier).next();
      final afterNext = container.read(selectedMonthProvider);
      container.read(selectedMonthProvider.notifier).previous();
      final afterPrev = container.read(selectedMonthProvider);

      expect(afterPrev.month, isNot(afterNext.month));
    });

    test('next() يتعامل مع انتقال السنة (ديسمبر → يناير)', () {
      // نذهب لديسمبر أولاً
      final now = DateTime.now();
      final monthsToAdd = 12 - now.month;
      for (var i = 0; i < monthsToAdd; i++) {
        container.read(selectedMonthProvider.notifier).next();
      }
      final dec = container.read(selectedMonthProvider);
      expect(dec.month, 12);

      // ننتقل لشهر التالي
      container.read(selectedMonthProvider.notifier).next();
      final jan = container.read(selectedMonthProvider);
      expect(jan.month, 1);
      expect(jan.year, dec.year + 1);
    });

    test('previous() يتعامل مع انتقال السنة (يناير → ديسمبر)', () {
      final now = DateTime.now();
      // نذهب ليناير
      for (var i = 0; i < now.month - 1; i++) {
        container.read(selectedMonthProvider.notifier).previous();
      }
      final jan = container.read(selectedMonthProvider);
      expect(jan.month, 1);

      container.read(selectedMonthProvider.notifier).previous();
      final dec = container.read(selectedMonthProvider);
      expect(dec.month, 12);
      expect(dec.year, jan.year - 1);
    });

    test('goToToday() يعود للشهر الحالي', () {
      // ننتقل بعيداً
      for (var i = 0; i < 5; i++) {
        container.read(selectedMonthProvider.notifier).next();
      }

      container.read(selectedMonthProvider.notifier).goToToday();
      final month = container.read(selectedMonthProvider);
      final now = DateTime.now();
      expect(month.month, now.month);
      expect(month.year, now.year);
    });
  });

  group('selectedDayProvider —', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('القيمة الابتدائية null', () {
      expect(container.read(selectedDayProvider), isNull);
    });

    test('يقبل تاريخاً صحيحاً', () {
      final date = DateTime(2026, 10, 15);
      container.read(selectedDayProvider.notifier).state = date;
      expect(container.read(selectedDayProvider), date);
    });
  });
}
