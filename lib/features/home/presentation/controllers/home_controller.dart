import 'package:flutter/foundation.dart';
import 'package:mivent/features/home/data/repositories/booking_repository.dart';
import 'package:mivent/features/home/domain/models/booking.dart';

/// متحكم الشاشة الرئيسية — يدير التقويم والحجوزات والحالات.
class HomeController extends ChangeNotifier {
  HomeController({required this._repository});

  final BookingRepository _repository;

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  List<Booking> _monthBookings = const [];
  List<Booking> _dayBookings = const [];
  HomeLoadState _loadState = HomeLoadState.loading;
  String? _errorMessage;
  bool _isOnline = true;
  int _selectedTab = 0;

  // فلاتر قائمة الحجوزات
  BookingFilter _filter = BookingFilter.all;

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDate => _selectedDate;
  List<Booking> get monthBookings => _monthBookings;
  List<Booking> get dayBookings => _dayBookings;
  HomeLoadState get loadState => _loadState;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  int get selectedTab => _selectedTab;
  BookingFilter get filter => _filter;

  Set<int> get bookedDayNumbers {
    return _monthBookings.map((b) => b.date.day).toSet();
  }

  Map<int, BookingStatus> get dayStatusMap {
    final map = <int, BookingStatus>{};
    for (final b in _monthBookings) {
      final day = b.date.day;
      final existing = map[day];
      if (existing == null) {
        map[day] = b.status;
      } else if (existing == BookingStatus.confirmed &&
          b.status == BookingStatus.provisional) {
        // إذا وُجد مؤكد ومؤقت في نفس اليوم نُظهر مؤكد
        map[day] = BookingStatus.confirmed;
      }
    }
    return map;
  }

  int get bookedDaysCount => bookedDayNumbers.length;

  int get availableDaysCount {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    return daysInMonth - bookedDaysCount;
  }

  List<Booking> get filteredDayBookings {
    switch (_filter) {
      case BookingFilter.all:
        return _dayBookings;
      case BookingFilter.today:
        final now = DateTime.now();
        return _dayBookings
            .where(
              (b) =>
                  b.date.year == now.year &&
                  b.date.month == now.month &&
                  b.date.day == now.day,
            )
            .toList();
      case BookingFilter.upcoming:
        final now = DateTime.now();
        return _dayBookings
            .where(
              (b) => b.date.isAfter(DateTime(now.year, now.month, now.day)),
            )
            .toList();
      case BookingFilter.confirmed:
        return _dayBookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList();
      case BookingFilter.provisional:
        return _dayBookings
            .where((b) => b.status == BookingStatus.provisional)
            .toList();
    }
  }

  Future<void> init() async {
    await loadMonth(_focusedMonth);
    await selectDate(_selectedDate);
  }

  Future<void> loadMonth(DateTime month) async {
    _focusedMonth = DateTime(month.year, month.month);
    _loadState = HomeLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_isOnline) {
        _loadState = HomeLoadState.offline;
        _errorMessage = 'لا يوجد اتصال بالإنترنت';
        notifyListeners();
        return;
      }

      _monthBookings = await _repository.getBookingsForMonth(_focusedMonth);
      _loadState = HomeLoadState.ready;
    } catch (e) {
      _loadState = HomeLoadState.error;
      _errorMessage = 'تعذّر تحميل الحجوزات. حاول مرة أخرى.';
    }
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    if (_selectedDate.year != _focusedMonth.year ||
        _selectedDate.month != _focusedMonth.month) {
      await loadMonth(_selectedDate);
    }

    try {
      _dayBookings = await _repository.getBookingsForDate(_selectedDate);
    } catch (_) {
      _dayBookings = const [];
    }
    notifyListeners();
  }

  Future<void> changeMonth(int delta) async {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    await loadMonth(next);
    // عند تغيير الشهر نحدد أول يوم في الشهر إذا كان اليوم المحدد خارج الشهر
    if (_selectedDate.year != next.year || _selectedDate.month != next.month) {
      await selectDate(DateTime(next.year, next.month, 1));
    } else {
      await selectDate(_selectedDate);
    }
  }

  Future<void> goToToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await loadMonth(today);
    await selectDate(today);
  }

  void setFilter(BookingFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> retry() async {
    await loadMonth(_focusedMonth);
    await selectDate(_selectedDate);
  }

  void setOnline(bool online) {
    _isOnline = online;
    if (!online) {
      _loadState = HomeLoadState.offline;
      _errorMessage = 'لا يوجد اتصال بالإنترنت';
    }
    notifyListeners();
  }

  Future<void> simulateSync() async {
    _loadState = HomeLoadState.syncing;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await loadMonth(_focusedMonth);
    await selectDate(_selectedDate);
  }
}

enum BookingFilter { all, today, upcoming, confirmed, provisional }

extension BookingFilterX on BookingFilter {
  String get labelAr {
    switch (this) {
      case BookingFilter.all:
        return 'الكل';
      case BookingFilter.today:
        return 'اليوم';
      case BookingFilter.upcoming:
        return 'القادمة';
      case BookingFilter.confirmed:
        return 'مؤكد';
      case BookingFilter.provisional:
        return 'مؤقت';
    }
  }
}
