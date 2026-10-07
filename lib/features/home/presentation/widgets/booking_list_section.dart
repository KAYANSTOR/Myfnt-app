import 'package:flutter/material.dart';
import 'package:mivent/core/constants/app_colors.dart';
import 'package:mivent/features/home/domain/models/booking.dart';
import 'package:mivent/features/home/presentation/controllers/home_controller.dart';
import 'package:mivent/features/home/presentation/widgets/booking_card.dart';
import 'package:mivent/features/home/presentation/widgets/empty_state.dart';

class BookingListSection extends StatelessWidget {
  const BookingListSection({
    super.key,
    required this.controller,
    required this.onBookingTap,
    required this.onAddBooking,
  });

  final HomeController controller;
  final ValueChanged<Booking> onBookingTap;
  final VoidCallback onAddBooking;

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
  Widget build(BuildContext context) {
    final date = controller.selectedDate;
    final title =
        'حجوزات ${date.day} ${_monthNames[date.month - 1]} ${date.year}';
    final bookings = controller.dayBookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (bookings.isNotEmpty)
              Text(
                '${bookings.length} حجز',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // فلاتر سريعة
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: BookingFilter.values.map((f) {
              final selected = controller.filter == f;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: Text(f.labelAr),
                  selected: selected,
                  onSelected: (_) => controller.setFilter(f),
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFEDE8E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (bookings.isEmpty)
          EmptyState(
            icon: Icons.event_busy_rounded,
            title: 'لا توجد حجوزات في هذا اليوم',
            subtitle: 'اختر يومًا آخر أو أضف حجزًا جديدًا لهذا التاريخ.',
            actionLabel: 'إضافة حجز',
            onAction: onAddBooking,
          )
        else
          ..._buildFilteredList(bookings),
      ],
    );
  }

  List<Widget> _buildFilteredList(List<Booking> all) {
    List<Booking> list;
    switch (controller.filter) {
      case BookingFilter.all:
        list = all;
      case BookingFilter.today:
        final now = DateTime.now();
        list = all
            .where(
              (b) =>
                  b.date.year == now.year &&
                  b.date.month == now.month &&
                  b.date.day == now.day,
            )
            .toList();
      case BookingFilter.upcoming:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        list = all.where((b) => b.date.isAfter(today)).toList();
      case BookingFilter.confirmed:
        list = all.where((b) => b.status == BookingStatus.confirmed).toList();
      case BookingFilter.provisional:
        list = all.where((b) => b.status == BookingStatus.provisional).toList();
    }

    if (list.isEmpty) {
      return [
        EmptyState(
          icon: Icons.filter_list_off_rounded,
          title: 'لا نتائج لهذا الفلتر',
          subtitle: 'جرّب فلترًا آخر أو اعرض كل الحجوزات.',
        ),
      ];
    }

    return list
        .map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BookingCard(booking: b, onTap: () => onBookingTap(b)),
          ),
        )
        .toList();
  }
}
