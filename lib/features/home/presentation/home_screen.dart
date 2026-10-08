import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/presentation/add_booking_sheet.dart';
import '../../bookings/presentation/bookings_screen.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/home_header.dart';
import '../widgets/myfnt_bottom_navigation.dart';

/// الشاشة الرئيسية — تنسّق فقط، لا تحتوي منطقاً
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: HomeHeader(),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          const _CalendarTab(),
          const BookingsScreen(),
          const _PlaceholderTab(
            title: 'الدفعات',
            icon: Icons.account_balance_wallet_outlined,
            subtitle: 'إدارة المدفوعات والفواتير',
          ),
          const _PlaceholderTab(
            title: 'الملف الشخصي',
            icon: Icons.person_outline,
            subtitle: 'حدّث بيانات حسابك وإعداداتك',
          ),
        ],
      ),
      bottomNavigationBar: MyfntBottomNavigation(
        selectedIndex: _selectedTab,
        onIndexChanged: (i) => setState(() => _selectedTab = i),
        onAddPressed: () => showAddBookingSheet(context, DateTime.now()),
      ),
    );
  }
}

/// تبويب التقويم — يعرض التقويم القابل للطي ثم قسم الحجوزات
class _CalendarTab extends ConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CalendarGrid(),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        thickness: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'الحجوزات',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'مؤقت', selected: false),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'مؤكد', selected: true),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'القادمة', selected: false),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'اليوم', selected: false),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'الكل', selected: false),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const BookingSummaryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFE8E0DC),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }
}

/// Placeholder للتبويبات غير المكتملة
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 42, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppColors.textMid)),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('إضافة جديد'),
            ),
          ],
        ),
      ),
    );
  }
}
