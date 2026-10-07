import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mivent/core/database/app_database.dart';
import 'package:mivent/features/bookings/data/booking_repository.dart';
import 'package:mivent/features/bookings/domain/booking.dart';

/// ينشئ DB في الذاكرة — سريع ولا يترك أثراً على الجهاز
AppDatabase _inMemoryDb() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late BookingRepository repo;

  setUp(() {
    db = _inMemoryDb();
    repo = BookingRepository(db.bookingsDao);
  });

  tearDown(() => db.close());

  group('BookingRepository CRUD —', () {
    test('إضافة حجز وقراءته', () async {
      final id = await repo.addBooking(
        customerName: 'فاطمة علي',
        date: DateTime(2026, 10, 20),
        status: BookingStatus.confirmed,
      );

      expect(id, greaterThan(0));

      final bookings = await db.bookingsDao.getAll();
      expect(bookings.length, 1);
      expect(bookings.first.customerName, 'فاطمة علي');
    });

    test('تحديث حجز موجود', () async {
      final id = await repo.addBooking(
        customerName: 'محمد',
        date: DateTime(2026, 10, 10),
        status: BookingStatus.pending,
      );

      final original = await db.bookingsDao.getById(id);
      expect(original, isNotNull);

      final booking = Booking(
        id: id,
        customerName: 'محمد خالد', // اسم محدَّث
        date: DateTime(2026, 10, 10),
        status: BookingStatus.confirmed, // حالة محدَّثة
      );
      await repo.updateBooking(booking);

      final updated = await db.bookingsDao.getById(id);
      expect(updated!.customerName, 'محمد خالد');
      expect(updated.status, 'confirmed');
    });

    test('حذف حجز', () async {
      final id = await repo.addBooking(
        customerName: 'خالد',
        date: DateTime(2026, 10, 5),
        status: BookingStatus.confirmed,
      );

      final before = await db.bookingsDao.getAll();
      expect(before.length, 1);

      await repo.deleteBooking(id);

      final after = await db.bookingsDao.getAll();
      expect(after, isEmpty);
    });

    test('إضافة أكثر من حجز ليوم واحد', () async {
      final date = DateTime(2026, 10, 15);
      await repo.addBooking(
        customerName: 'عميل 1',
        date: date,
        status: BookingStatus.confirmed,
      );
      await repo.addBooking(
        customerName: 'عميل 2',
        date: date,
        status: BookingStatus.partial,
      );

      final all = await db.bookingsDao.getAll();
      expect(all.length, 2);
    });
  });

  group('BookingRepository Streams —', () {
    test('watchByMonth يُرجع حجوزات الشهر الصحيح فقط', () async {
      await repo.addBooking(
        customerName: 'عميل أكتوبر',
        date: DateTime(2026, 10, 5),
        status: BookingStatus.confirmed,
      );
      await repo.addBooking(
        customerName: 'عميل نوفمبر',
        date: DateTime(2026, 11, 5),
        status: BookingStatus.confirmed,
      );

      final octBookings = await repo.watchByMonth(2026, 10).first;
      expect(octBookings.length, 1);
      expect(octBookings.first.customerName, 'عميل أكتوبر');
    });

    test('watchByMonth يتحدث عند إضافة حجز جديد', () async {
      final stream = repo.watchByMonth(2026, 10);

      // أول قيمة: فارغ
      final first = await stream.first;
      expect(first, isEmpty);

      // إضافة حجز
      await repo.addBooking(
        customerName: 'عميل جديد',
        date: DateTime(2026, 10, 8),
        status: BookingStatus.confirmed,
      );

      // القيمة الثانية: تحتوي الحجز
      final second = await repo.watchByMonth(2026, 10).first;
      expect(second.length, 1);
    });

    test('watchByDate يُرجع حجوزات اليوم المحدد فقط', () async {
      await repo.addBooking(
        customerName: 'عميل يوم 10',
        date: DateTime(2026, 10, 10, 9, 0),
        status: BookingStatus.confirmed,
      );
      await repo.addBooking(
        customerName: 'عميل يوم 11',
        date: DateTime(2026, 10, 11, 9, 0),
        status: BookingStatus.confirmed,
      );

      final day10 = await repo.watchByDate(DateTime(2026, 10, 10)).first;
      expect(day10.length, 1);
      expect(day10.first.customerName, 'عميل يوم 10');
    });
  });

  group('BookingRepository حالات الحواف —', () {
    test('قائمة فارغة عند عدم وجود حجوزات', () async {
      final bookings = await repo.watchByMonth(2026, 10).first;
      expect(bookings, isEmpty);
    });

    test('يحتفظ بالتاريخ الحقيقي بدقة', () async {
      final date = DateTime(2026, 12, 31, 23, 59);
      final id = await repo.addBooking(
        customerName: 'عميل آخر يوم',
        date: date,
        status: BookingStatus.confirmed,
      );

      final row = await db.bookingsDao.getById(id);
      expect(row!.date.year, 2026);
      expect(row.date.month, 12);
      expect(row.date.day, 31);
    });
  });
}
