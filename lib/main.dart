import 'package:flutter/material.dart';

void main() {
  runApp(const MiventApp());
}

class MiventApp extends StatelessWidget {
  const MiventApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF355C7D);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ميفنت',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          surface: const Color(0xFFF7F9FC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9FC),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _month = DateTime.now();
  int _selectedTab = 0;
  final Set<int> _bookedDays = {3, 7, 12, 19, 24};

  static const monthNames = <String>[
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
  static const weekDays = <String>[
    'أحد',
    'اثن',
    'ثلا',
    'أرب',
    'خمي',
    'جمع',
    'سبت',
  ];

  String get monthTitle => '${monthNames[_month.month - 1]} ${_month.year}';

  void _changeMonth(int amount) {
    setState(() {
      _month = DateTime(_month.year, _month.month + amount);
    });
  }

  void _showDayDetails(int day) {
    final isBooked = _bookedDays.contains(day);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل $day ${monthNames[_month.month - 1]}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  isBooked ? Icons.event_available : Icons.event_note,
                  color: isBooked
                      ? const Color(0xFF2E8B72)
                      : const Color(0xFF355C7D),
                ),
                const SizedBox(width: 10),
                Text(
                  isBooked
                      ? 'يوجد حجز مؤكد في هذا اليوم'
                      : 'اليوم متاح لاستقبال الحجوزات',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() => _bookedDays.add(day));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ الحجز بنجاح')),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(isBooked ? 'إضافة حجز آخر' : 'إضافة حجز'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 22,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً بك في ميفنت',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'لوحة التحكم',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        actions: [
          _HeaderIcon(
            icon: Icons.notifications_none_rounded,
            badge: '3',
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(left: 18, right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFDCE9F2),
              child: Icon(Icons.person_outline, color: Color(0xFF355C7D)),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _calendarPage(),
          _simplePage(
            'الحجوزات',
            Icons.event_note,
            'تابع كل حجوزاتك في مكان واحد',
          ),
          _simplePage(
            'الدفعات',
            Icons.account_balance_wallet_outlined,
            'إدارة المدفوعات والفواتير',
          ),
          _simplePage(
            'الملف الشخصي',
            Icons.person_outline,
            'حدّث بيانات حسابك وإعداداتك',
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showDayDetails(DateTime.now().day),
              backgroundColor: const Color(0xFF355C7D),
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
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDCE9F2),
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

  Widget _calendarPage() {
    final now = DateTime.now();
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;
    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      final isBooked = _bookedDays.contains(day);
      final isPartial = day % 5 == 0 || day == 16;
      cells.add(
        _DayCell(
          day: day,
          isToday: isToday,
          isBooked: isBooked,
          isPartial: isPartial,
          onTap: () => _showDayDetails(day),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCard(
            booked: _bookedDays.length,
            available: daysInMonth - _bookedDays.length,
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تقويم الحجوزات',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              TextButton.icon(
                onPressed: () => _changeMonth(0),
                icon: const Icon(Icons.today_outlined, size: 18),
                label: const Text('اليوم'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _changeMonth(-1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                      Column(
                        children: [
                          Text(
                            monthTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'اضغط على اليوم لعرض التفاصيل',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8A98A8),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _changeMonth(1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: weekDays
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8A98A8),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 9),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 5,
                    childAspectRatio: .84,
                    children: cells,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'دليل الحالات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: const [
              _Legend(color: Color(0xFF2E8B72), label: 'محجوز'),
              _Legend(color: Color(0xFFF0B35B), label: 'جزئي'),
              _Legend(color: Color(0xFFE7EDF2), label: 'متاح'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simplePage(String title, IconData icon, String subtitle) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE9F2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(icon, size: 42, color: const Color(0xFF355C7D)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Color(0xFF718096))),
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

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.badge,
    required this.onTap,
  });
  final IconData icon;
  final String badge;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 27, color: const Color(0xFF355C7D)),
      ),
      Positioned(
        top: 5,
        right: 5,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Color(0xFFE76F51),
            shape: BoxShape.circle,
          ),
          child: Text(
            badge,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.booked, required this.available});
  final int booked;
  final int available;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF355C7D), Color(0xFF4E809E)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF355C7D).withValues(alpha: .2),
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
        _Stat(value: '$booked', label: 'محجوز'),
        Container(width: 1, height: 32, color: Colors.white24),
        _Stat(value: '$available', label: 'متاح'),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Padding(
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

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
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
        style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
      ),
    ],
  );
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isBooked,
    required this.isPartial,
    required this.onTap,
  });
  final int day;
  final bool isToday, isBooked, isPartial;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final bg = isBooked
        ? const Color(0xFFE4F3EE)
        : isPartial
        ? const Color(0xFFFFF3DF)
        : const Color(0xFFF5F7FA);
    final fg = isBooked
        ? const Color(0xFF26745F)
        : isPartial
        ? const Color(0xFFB97818)
        : const Color(0xFF536273);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFF355C7D) : bg,
          borderRadius: BorderRadius.circular(13),
          border: isToday ? null : Border.all(color: Colors.transparent),
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
                color: isToday
                    ? Colors.white
                    : isBooked
                    ? const Color(0xFF2E8B72)
                    : isPartial
                    ? const Color(0xFFF0B35B)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
