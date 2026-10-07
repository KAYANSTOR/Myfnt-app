import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/providers/booking_providers.dart';

/// بطاقة ملخص الشهر — تتحدث تلقائياً عند تغيير البيانات
/// مفصولة عن التقويم لتجنب إعادة بناء غير ضرورية
class BookingSummaryCard extends ConsumerWidget {
  const BookingSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // نستمع للملخص فقط وليس للقائمة كاملة
    final summary = ref.watch(monthSummaryProvider);

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص الشهر',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 3),
                Text(
                  'نظّم مواعيدك بسهولة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _StatChip(value: '${summary.bookedDays}', label: 'محجوز'),
          Container(width: 1, height: 32, color: Colors.white24),
          _StatChip(value: '${summary.availableDays}', label: 'متاح'),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
