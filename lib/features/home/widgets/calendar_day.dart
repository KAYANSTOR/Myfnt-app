import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/domain/booking.dart';

/// خلية يوم واحد في التقويم
/// تتلقى البيانات كـ parameters — لا تعرف شيئاً عن Riverpod أو DB
class CalendarDay extends StatelessWidget {
  const CalendarDay({
    super.key,
    required this.day,
    required this.isToday,
    required this.bookings,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final List<Booking> bookings; // قائمة الحجوزات الحقيقية
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _dayStatus();
    final bg = _bgColor(status);
    final fg = _fgColor(status);
    final dotColor = _dotColor(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? AppColors.primary : bg,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isToday ? Colors.white : fg,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isToday ? Colors.white : dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _DayStatus _dayStatus() {
    if (bookings.isEmpty) return _DayStatus.available;
    final hasConfirmed = bookings.any(
      (b) => b.status == BookingStatus.confirmed,
    );
    if (hasConfirmed) return _DayStatus.booked;
    final hasPartial = bookings.any((b) => b.status == BookingStatus.partial);
    if (hasPartial) return _DayStatus.partial;
    return _DayStatus.available;
  }

  Color _bgColor(_DayStatus s) {
    switch (s) {
      case _DayStatus.booked:
        return AppColors.primaryLight;
      case _DayStatus.partial:
        return AppColors.primaryLight;
      case _DayStatus.available:
        return AppColors.surface;
    }
  }

  Color _fgColor(_DayStatus s) {
    switch (s) {
      case _DayStatus.booked:
        return AppColors.booked;
      case _DayStatus.partial:
        return AppColors.partial;
      case _DayStatus.available:
        return const Color(0xFF64748B);
    }
  }

  Color _dotColor(_DayStatus s) {
    switch (s) {
      case _DayStatus.booked:
        return AppColors.booked;
      case _DayStatus.partial:
        return AppColors.partial;
      case _DayStatus.available:
        return Colors.transparent;
    }
  }
}

enum _DayStatus { booked, partial, available }
