import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/domain/booking.dart';

/// خلية يوم واحدة في تقويم ميفنت.
class CalendarDay extends StatelessWidget {
  const CalendarDay({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.bookings,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isSelected;
  final List<Booking> bookings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _dayStatus();
    final isActive = isToday || isSelected;
    final background = isActive
        ? AppColors.primary
        : status == _DayStatus.available
            ? AppColors.surface
            : AppColors.primaryLight.withValues(alpha: .72);
    final foreground = isActive ? Colors.white : _fgColor(status);

    return Semantics(
      button: true,
      label: '$day، ${bookings.length} حجوزات',
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(15),
            border: isSelected && !isToday
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            boxShadow: isToday
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: .28), blurRadius: 9, offset: const Offset(0, 4))]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: foreground),
              ),
              const SizedBox(height: 4),
              if (bookings.isNotEmpty)
                Text(
                  '${bookings.length}',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: foreground.withValues(alpha: .78)),
                )
              else
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white70 : _dotColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _DayStatus _dayStatus() {
    if (bookings.isEmpty) return _DayStatus.available;
    if (bookings.any((b) => b.status == BookingStatus.confirmed)) return _DayStatus.booked;
    if (bookings.any((b) => b.status == BookingStatus.partial)) return _DayStatus.partial;
    return _DayStatus.available;
  }

  Color _fgColor(_DayStatus status) {
    switch (status) {
      case _DayStatus.booked:
        return AppColors.booked;
      case _DayStatus.partial:
        return AppColors.partial;
      case _DayStatus.available:
        return const Color(0xFF64748B);
    }
  }

  Color _dotColor(_DayStatus status) {
    switch (status) {
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
