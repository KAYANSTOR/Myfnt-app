import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/domain/booking.dart';
import '../../bookings/providers/booking_providers.dart';
import 'calendar_day.dart';
import 'month_navigator.dart';

/// شبكة التقويم الكاملة
/// تقرأ من monthBookingsMapProvider فقط — لا تعرف شيئاً عن DB
class CalendarGrid extends ConsumerWidget {
  const CalendarGrid({super.key});

  static const _weekDays = ['أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final bookingsMap = ref.watch(monthBookingsMapProvider);
    final asyncBookings = ref.watch(monthBookingsProvider);

    final now = DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // الأحد = 0 في Flutter weekday % 7
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
        child: Column(
          children: [
            const MonthNavigator(),
            const SizedBox(height: 12),
            // رؤوس أيام الأسبوع
            Row(
              children: _weekDays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMid,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 9),
            // حالة التحميل — فقط المرة الأولى
            if (asyncBookings.isLoading && bookingsMap.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 5,
                childAspectRatio: .84,
                children: [
                  // خلايا فارغة قبل بداية الشهر
                  for (var i = 0; i < firstWeekday; i++) const SizedBox(),
                  // أيام الشهر
                  for (var day = 1; day <= daysInMonth; day++)
                    _buildDayCell(ref, month, day, now, bookingsMap),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    WidgetRef ref,
    DateTime month,
    int day,
    DateTime now,
    Map<DateTime, List<Booking>> bookingsMap,
  ) {
    final date = DateTime(month.year, month.month, day);
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final dayBookings = bookingsMap[date] ?? const <Booking>[];

    return CalendarDay(
      day: day,
      isToday: isToday,
      bookings: dayBookings,
      onTap: () {
        ref.read(selectedDayProvider.notifier).state = date;
      },
    );
  }
}

/// دليل حالات الأيام
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: const [
        _LegendItem(color: AppColors.booked, label: 'محجوز'),
        _LegendItem(color: AppColors.partial, label: 'جزئي'),
        _LegendItem(color: AppColors.available, label: 'متاح'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMid),
        ),
      ],
    );
  }
}
