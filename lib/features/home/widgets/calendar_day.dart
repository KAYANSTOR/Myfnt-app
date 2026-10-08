import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/domain/booking.dart';

/// خلية يوم واحد — تصميم مطابق للمرجع (مستدير + تسمية "اليوم")
class CalendarDay extends StatelessWidget {
  const CalendarDay({
    super.key,
    required this.day,
    required this.isToday,
    required this.isCurrentMonth,
    required this.bookings,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isCurrentMonth;
  final List<Booking> bookings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _dayStatus();

    return GestureDetector(
      onTap: isCurrentMonth ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? AppColors.primary
                : const Color(0xFFF0E6EB),
            width: isToday ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isCurrentMonth
                    ? (isToday ? AppColors.primary : AppColors.textDark)
                    : AppColors.textLight,
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: 2),
              Text(
                'اليوم',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
            ] else if (isCurrentMonth && status != _DayStatus.available) ...[
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: status == _DayStatus.booked
                      ? AppColors.booked
                      : AppColors.partial,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _DayStatus _dayStatus() {
    if (bookings.isEmpty) return _DayStatus.available;
    final hasConfirmed =
        bookings.any((b) => b.status == BookingStatus.confirmed);
    if (hasConfirmed) return _DayStatus.booked;
    final hasPartial =
        bookings.any((b) => b.status == BookingStatus.partial);
    if (hasPartial) return _DayStatus.partial;
    return _DayStatus.available;
  }
}

enum _DayStatus { booked, partial, available }
