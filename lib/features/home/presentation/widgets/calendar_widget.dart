import 'package:flutter/material.dart';
import 'package:mivent/core/constants/app_colors.dart';
import 'package:mivent/features/home/domain/models/booking.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.dayStatusMap,
    required this.onDayTap,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onGoToday,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Map<int, BookingStatus> dayStatusMap;
  final ValueChanged<DateTime> onDayTap;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onGoToday;

  static const _monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  // يبدأ الأسبوع من السبت ليتوافق مع الموقع المرجعي
  static const _weekDays = ['سبت', 'أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع'];

  String get _monthTitle =>
      '${_monthNames[focusedMonth.month - 1]} ${focusedMonth.year}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    // weekday: Mon=1 ... Sun=7 → نحول ليصبح السبت = 0
    final firstWeekday =
        (DateTime(focusedMonth.year, focusedMonth.month, 1).weekday + 1) % 7;

    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      final isSelected =
          date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
      final status = dayStatusMap[day];

      cells.add(
        _DayCell(
          day: day,
          isToday: isToday,
          isSelected: isSelected,
          status: status,
          onTap: () => onDayTap(date),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      child: Column(
        children: [
          // شريط الشهر
          Row(
            children: [
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.primary,
                tooltip: 'الشهر التالي',
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _monthTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: onGoToday,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'اليوم',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPrevMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.primary,
                tooltip: 'الشهر السابق',
              ),
            ],
          ),
          const SizedBox(height: 10),
          // أيام الأسبوع
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
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
            childAspectRatio: 0.9,
            children: cells,
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.status,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isSelected;
  final BookingStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.background;
    Color fg = AppColors.textMuted;
    Color? dot;

    if (isSelected) {
      bg = AppColors.primary;
      fg = Colors.white;
      dot = Colors.white;
    } else if (isToday) {
      bg = AppColors.primaryLight.withValues(alpha: 0.55);
      fg = AppColors.primaryDark;
      if (status != null) {
        dot = status!.isConfirmed ? AppColors.confirmed : AppColors.provisional;
      } else {
        dot = AppColors.primary;
      }
    } else if (status != null) {
      bg = AppColors.primaryLight.withValues(alpha: 0.35);
      fg = status!.isConfirmed ? AppColors.confirmed : AppColors.provisional;
      dot = fg;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: isToday && !isSelected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: dot ?? Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
