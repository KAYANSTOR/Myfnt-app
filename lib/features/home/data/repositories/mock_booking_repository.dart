import 'package:mivent/features/home/data/repositories/booking_repository.dart';
import 'package:mivent/features/home/domain/models/booking.dart';

/// مستودع تجريبي بحجوزات مرتبطة بتواريخ حقيقية (DateTime).
class MockBookingRepository implements BookingRepository {
  MockBookingRepository({DateTime? seedDate}) {
    final now = seedDate ?? DateTime.now();
    _seed(now);
  }

  late final List<Booking> _bookings;

  void _seed(DateTime now) {
    final y = now.year;
    final m = now.month;

    // حجوزات الشهر الحالي
    final current = <Booking>[
      Booking(
        id: 'b1',
        customerName: 'سارة الأحمد',
        date: DateTime(y, m, _safeDay(y, m, 3)),
        startTime: '16:00',
        endTime: '22:00',
        packageName: 'باقة ذهبية',
        status: BookingStatus.confirmed,
        amount: 8500,
        paid: 8500,
      ),
      Booking(
        id: 'b2',
        customerName: 'محمد العتيبي',
        date: DateTime(y, m, _safeDay(y, m, 7)),
        startTime: '14:00',
        endTime: '20:00',
        packageName: 'باقة فضية',
        status: BookingStatus.provisional,
        amount: 5200,
        paid: 1500,
      ),
      Booking(
        id: 'b3',
        customerName: 'نورة القحطاني',
        date: DateTime(y, m, _safeDay(y, m, 12)),
        startTime: '18:00',
        endTime: '23:00',
        packageName: 'باقة بلاتينية',
        status: BookingStatus.confirmed,
        amount: 12000,
        paid: 12000,
      ),
      Booking(
        id: 'b4',
        customerName: 'خالد الشمري',
        date: DateTime(y, m, _safeDay(y, m, 12)),
        startTime: '10:00',
        endTime: '14:00',
        packageName: 'باقة أساسية',
        status: BookingStatus.confirmed,
        amount: 3500,
        paid: 3500,
      ),
      Booking(
        id: 'b5',
        customerName: 'فاطمة الزهراني',
        date: DateTime(y, m, _safeDay(y, m, 19)),
        startTime: '15:00',
        endTime: '21:00',
        packageName: 'باقة ذهبية',
        status: BookingStatus.provisional,
        amount: 7800,
        paid: 2000,
      ),
      Booking(
        id: 'b6',
        customerName: 'عبدالله الدوسري',
        date: DateTime(y, m, _safeDay(y, m, 24)),
        startTime: '17:00',
        endTime: '23:30',
        packageName: 'باقة VIP',
        status: BookingStatus.confirmed,
        amount: 15000,
        paid: 15000,
      ),
    ];

    // حجوزات الشهر السابق
    final prev = DateTime(y, m - 1);
    final py = prev.year;
    final pm = prev.month;
    final previous = <Booking>[
      Booking(
        id: 'bp1',
        customerName: 'ريم الحربي',
        date: DateTime(py, pm, _safeDay(py, pm, 10)),
        startTime: '16:00',
        endTime: '21:00',
        packageName: 'باقة فضية',
        status: BookingStatus.confirmed,
        amount: 4800,
        paid: 4800,
      ),
      Booking(
        id: 'bp2',
        customerName: 'يوسف المطيري',
        date: DateTime(py, pm, _safeDay(py, pm, 22)),
        startTime: '14:00',
        endTime: '19:00',
        packageName: 'باقة أساسية',
        status: BookingStatus.provisional,
        amount: 3200,
        paid: 800,
      ),
    ];

    // حجوزات الشهر القادم
    final next = DateTime(y, m + 1);
    final ny = next.year;
    final nm = next.month;
    final upcoming = <Booking>[
      Booking(
        id: 'bn1',
        customerName: 'هند السبيعي',
        date: DateTime(ny, nm, _safeDay(ny, nm, 5)),
        startTime: '18:00',
        endTime: '23:00',
        packageName: 'باقة بلاتينية',
        status: BookingStatus.confirmed,
        amount: 11000,
        paid: 5000,
      ),
      Booking(
        id: 'bn2',
        customerName: 'سلمان الغامدي',
        date: DateTime(ny, nm, _safeDay(ny, nm, 15)),
        startTime: '12:00',
        endTime: '17:00',
        packageName: 'باقة ذهبية',
        status: BookingStatus.provisional,
        amount: 9000,
        paid: 2500,
      ),
    ];

    _bookings = [...previous, ...current, ...upcoming];
  }

  static int _safeDay(int year, int month, int day) {
    final max = DateTime(year, month + 1, 0).day;
    return day.clamp(1, max);
  }

  @override
  Future<List<Booking>> getAllBookings() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_bookings);
  }

  @override
  Future<List<Booking>> getBookingsForMonth(DateTime month) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final list = _bookings.where((b) => b.isInMonth(month)).toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return a.startTime.compareTo(b.startTime);
      });
    return List.unmodifiable(list);
  }

  @override
  Future<List<Booking>> getBookingsForDate(DateTime date) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final list = _bookings.where((b) => b.isOnDate(date)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return List.unmodifiable(list);
  }
}
