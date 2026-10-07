import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/providers/booking_providers.dart';

/// شريط التنقل بين الأشهر — يستمع للشهر الحالي فقط
class MonthNavigator extends ConsumerWidget {
  const MonthNavigator({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final notifier = ref.read(selectedMonthProvider.notifier);
    final label = '${_monthNames[month.month - 1]} ${month.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: notifier.previous,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'الشهر السابق',
        ),
        Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            const Text(
              'اضغط على اليوم لعرض التفاصيل',
              style: TextStyle(fontSize: 11, color: AppColors.textMid),
            ),
          ],
        ),
        IconButton(
          onPressed: notifier.next,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'الشهر التالي',
        ),
      ],
    );
  }
}
