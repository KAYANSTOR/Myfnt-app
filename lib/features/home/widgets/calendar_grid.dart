import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/domain/booking.dart';
import '../../bookings/providers/booking_providers.dart';
import 'calendar_day.dart';
import 'month_navigator.dart';

/// التقويم القابل للطي — شريط التنقل ثابت دائمًا
class CalendarGrid extends ConsumerStatefulWidget {
  const CalendarGrid({super.key});

  @override
  ConsumerState<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends ConsumerState<CalendarGrid>
    with SingleTickerProviderStateMixin {
  // يبدأ مفتوحًا كما طُلب
  bool _isExpanded = true;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  // أيام الأسبوع — تبدأ من السبت (RTL مطابق للمرجع)
  static const _weekDays = ['سبت', 'أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    // يبدأ مفتوحًا
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    final bookingsMap = ref.watch(monthBookingsMapProvider);
    final asyncBookings = ref.watch(monthBookingsProvider);

    final now = DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // بداية الأسبوع من السبت (Sat = 0)
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final startOffset = (firstOfMonth.weekday + 1) % 7;

    return Column(
      children: [
        // ── شريط التنقل (دائم الظهور) ──
        const MonthNavigator(),

        const SizedBox(height: 10),

        // ── مقبض الطي / الفتح ──
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 48,
            height: 22,
            alignment: Alignment.center,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.0 : 0.5,
              duration: const Duration(milliseconds: 280),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E0DC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 16,
                  color: AppColors.textMid,
                ),
              ),
            ),
          ),
        ),

        // ── جسم التقويم (قابل للطي) ──
        SizeTransition(
          sizeFactor: _expandAnimation,
          alignment: Alignment.topCenter,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
              child: Column(
                children: [
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
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMid,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),

                  // الشبكة
                  if (asyncBookings.isLoading && bookingsMap.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    _buildGrid(
                      month: month,
                      daysInMonth: daysInMonth,
                      startOffset: startOffset,
                      now: now,
                      bookingsMap: bookingsMap,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid({
    required DateTime month,
    required int daysInMonth,
    required int startOffset,
    required DateTime now,
    required Map<DateTime, List<Booking>> bookingsMap,
  }) {
    final prevMonth = DateTime(month.year, month.month, 0);
    final daysInPrev = prevMonth.day;

    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final totalSlots = rows * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalSlots,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 5,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        if (index < startOffset) {
          final day = daysInPrev - startOffset + index + 1;
          return CalendarDay(
            day: day,
            isToday: false,
            isCurrentMonth: false,
            bookings: const [],
            onTap: () {},
          );
        }

        final dayIndex = index - startOffset;
        if (dayIndex < daysInMonth) {
          final day = dayIndex + 1;
          final date = DateTime(month.year, month.month, day);
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
          final dayBookings = bookingsMap[date] ?? const <Booking>[];

          return CalendarDay(
            day: day,
            isToday: isToday,
            isCurrentMonth: true,
            bookings: dayBookings,
            onTap: () {
              ref.read(selectedDayProvider.notifier).state = date;
            },
          );
        }

        final nextDay = dayIndex - daysInMonth + 1;
        return CalendarDay(
          day: nextDay,
          isToday: false,
          isCurrentMonth: false,
          bookings: const [],
          onTap: () {},
        );
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
