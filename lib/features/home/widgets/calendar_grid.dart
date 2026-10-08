import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/domain/booking.dart';
import '../../bookings/providers/booking_providers.dart';
import 'calendar_day.dart';
import 'month_navigator.dart';

/// تقويم الحجوزات الاحترافي لميفنت.
/// يبقى مرتبطاً بمزودي Riverpod الحاليين، لذلك لا يتغير منطق قاعدة البيانات.
class CalendarGrid extends ConsumerWidget {
  const CalendarGrid({super.key});

  static const _weekDays = ['أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final bookingsMap = ref.watch(monthBookingsMapProvider);
    final asyncBookings = ref.watch(monthBookingsProvider);
    final summary = ref.watch(monthSummaryProvider);
    final now = DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Column(
          children: [
            _CalendarHeader(summary: summary),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              child: Column(
                children: [
                  const MonthNavigator(),
                  const SizedBox(height: 15),
                  Row(
                    children: _weekDays
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  color: AppColors.textMid,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  if (asyncBookings.isLoading && bookingsMap.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 7,
                      crossAxisSpacing: 5,
                      childAspectRatio: .78,
                      children: [
                        for (var i = 0; i < firstWeekday; i++) const SizedBox(),
                        for (var day = 1; day <= daysInMonth; day++)
                          _buildDayCell(ref, month, day, now, bookingsMap),
                      ],
                    ),
                ],
              ),
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
    final selectedDay = ref.watch(selectedDayProvider);
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isSelected = selectedDay != null &&
        date.year == selectedDay.year &&
        date.month == selectedDay.month &&
        date.day == selectedDay.day;

    return CalendarDay(
      day: day,
      isToday: isToday,
      isSelected: isSelected,
      bookings: bookingsMap[date] ?? const <Booking>[],
      onTap: () => ref.read(selectedDayProvider.notifier).state = date,
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.summary});
  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 17),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نظرة عامة', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('مواعيدك هذا الشهر', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          _SummaryValue(value: '${summary.bookedDays}', label: 'محجوز'),
          const SizedBox(width: 18),
          _SummaryValue(value: '${summary.availableDays}', label: 'متاح'),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

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
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMid, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
