import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookings/presentation/add_booking_sheet.dart';
import '../../bookings/providers/booking_providers.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/home_header.dart';

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
        preferredSize: Size.fromHeight(76),
        child: HomeHeader(),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _CalendarTab(),
          _PlaceholderTab(
            title: 'الحجوزات',
            icon: Icons.event_note,
            subtitle: 'تابع كل حجوزاتك في مكان واحد',
          ),
          _PlaceholderTab(
            title: 'الدفعات',
            icon: Icons.account_balance_wallet_outlined,
            subtitle: 'إدارة المدفوعات والفواتير',
          ),
          _PlaceholderTab(
            title: 'الملف الشخصي',
            icon: Icons.person_outline,
            subtitle: 'حدّث بيانات حسابك وإعداداتك',
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => showAddBookingSheet(context, DateTime.now()),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'حجز جديد',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) => setState(() => _selectedTab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'التقويم',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'الحجوزات',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'الدفعات',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

/// تبويب التقويم
class _CalendarTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BookingSummaryCard(),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تقويم الحجوزات',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    ref.read(selectedMonthProvider.notifier).goToToday(),
                icon: const Icon(Icons.today_outlined, size: 18),
                label: const Text('اليوم'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const CalendarGrid(),
          const SizedBox(height: 18),
          const Text(
            'دليل الحالات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 11),
          const CalendarLegend(),
        ],
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
