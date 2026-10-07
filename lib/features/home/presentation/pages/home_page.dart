import 'package:flutter/material.dart';
import 'package:mivent/core/constants/app_colors.dart';
import 'package:mivent/features/home/data/repositories/mock_booking_repository.dart';
import 'package:mivent/features/home/domain/models/booking.dart';
import 'package:mivent/features/home/presentation/controllers/home_controller.dart';
import 'package:mivent/features/home/presentation/widgets/booking_detail_sheet.dart';
import 'package:mivent/features/home/presentation/widgets/booking_list_section.dart';
import 'package:mivent/features/home/presentation/widgets/calendar_widget.dart';
import 'package:mivent/features/home/presentation/widgets/empty_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(repository: MockBookingRepository());
    _controller.addListener(_onUpdate);
    _controller.init();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: _controller.selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => showAddBookingPlaceholder(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'حجز جديد',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _controller.selectedTab,
        onDestinationSelected: _controller.setTab,
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // شعار واسم
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ميفنت',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _controller.isOnline
                            ? AppColors.online
                            : AppColors.offline,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _controller.isOnline ? 'متصل • محلي' : 'غير متصل',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // أيقونات
          _HeaderIcon(
            icon: Icons.notifications_none_rounded,
            badge: '0',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لا توجد إشعارات جديدة')),
              );
            },
          ),
          _HeaderIcon(
            icon: Icons.search_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('البحث سيُفعّل لاحقًا')),
              );
            },
          ),
          _HeaderIcon(
            icon: Icons.sync_rounded,
            onTap: () => _controller.simulateSync(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_controller.selectedTab) {
      case 0:
        return _buildCalendarTab();
      case 1:
        return _simplePlaceholder(
          'الحجوزات',
          Icons.event_note_rounded,
          'تابع كل حجوزاتك في مكان واحد',
        );
      case 2:
        return _simplePlaceholder(
          'الدفعات',
          Icons.payments_rounded,
          'إدارة سندات القبض والمدفوعات',
        );
      case 3:
        return _simplePlaceholder(
          'حسابي',
          Icons.person_rounded,
          'إعدادات الحساب والشركة',
        );
      default:
        return _buildCalendarTab();
    }
  }

  Widget _buildCalendarTab() {
    final state = _controller.loadState;

    if (state == HomeLoadState.loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'جاري التحميل...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (state == HomeLoadState.error) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'حدث خطأ',
        subtitle: _controller.errorMessage ?? 'تعذّر تحميل البيانات',
        actionLabel: 'إعادة المحاولة',
        onAction: _controller.retry,
      );
    }

    if (state == HomeLoadState.offline) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'غير متصل',
        subtitle: 'تحقق من اتصالك بالإنترنت ثم أعد المحاولة.',
        actionLabel: 'إعادة المحاولة',
        onAction: () {
          _controller.setOnline(true);
          _controller.retry();
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _controller.retry(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state == HomeLoadState.syncing)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.syncing.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.syncing.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.syncing,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'جاري المزامنة...',
                      style: TextStyle(
                        color: AppColors.syncing,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            // ملخص الشهر
            _SummaryCard(
              booked: _controller.bookedDaysCount,
              available: _controller.availableDaysCount,
            ),
            const SizedBox(height: 14),
            CalendarWidget(
              focusedMonth: _controller.focusedMonth,
              selectedDate: _controller.selectedDate,
              dayStatusMap: _controller.dayStatusMap,
              onDayTap: _controller.selectDate,
              onPrevMonth: () => _controller.changeMonth(-1),
              onNextMonth: () => _controller.changeMonth(1),
              onGoToday: _controller.goToToday,
            ),
            const SizedBox(height: 16),
            // دليل الحالات
            const Text(
              'دليل الحالات',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _Legend(color: AppColors.confirmed, label: 'مؤكد'),
                _Legend(color: AppColors.provisional, label: 'مؤقت'),
                _Legend(color: AppColors.available, label: 'متاح'),
              ],
            ),
            const SizedBox(height: 20),
            BookingListSection(
              controller: _controller,
              onBookingTap: (b) => showBookingDetailSheet(context, b),
              onAddBooking: () => showAddBookingPlaceholder(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simplePlaceholder(String title, IconData icon, String subtitle) {
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
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap, this.badge});

  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 24, color: AppColors.primary),
        ),
        if (badge != null && badge != '0')
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.booked, required this.available});

  final int booked;
  final int available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص الشهر',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text(
                  'نظّم مواعيدك بسهولة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _Stat(value: '$booked', label: 'محجوز'),
          Container(width: 1, height: 30, color: Colors.white24),
          _Stat(value: '$available', label: 'متاح'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

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
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
