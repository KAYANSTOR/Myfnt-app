import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfnt/core/company/company_service.dart';
import 'package:myfnt/core/database/app_database.dart';
import 'package:myfnt/features/bookings/data/booking_repository.dart';
import 'package:myfnt/features/bookings/domain/booking.dart';

AppDatabase _inMemoryDb() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late BookingRepository repo;

  setUp(() async {
    db = _inMemoryDb();
    await CompanyService(db).ensureLocalCompany();
    repo = BookingRepository(
      db: db,
      companyId: kLocalCompanyId,
      actorId: kLocalUserId,
      actorName: 'المستخدم المحلي',
    );
  });

  tearDown(() => db.close());

  group('BookingRepository CRUD —', () {
    test('إضافة حجز وقراءته', () async {
      final id = await repo.addBooking(
        customerName: 'فاطمة علي',
        date: DateTime(2026, 10, 20),
        status: BookingStatus.confirmed,
      );
      expect(id, isNotEmpty);
      final bookings = await db.bookingsDao.getAll();
      expect(bookings.length, 1);
      expect(bookings.first.customerNameSnapshot, 'فاطمة علي');
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
        customerId: original!.customerId,
        bookingNo: original.bookingNo,
        customerName: 'محمد خالد',
        eventDate: DateTime(2026, 10, 10),
        status: BookingStatus.confirmed,
      );
      await repo.updateBooking(booking);
      final updated = await db.bookingsDao.getById(id);
      expect(updated!.customerNameSnapshot, 'محمد خالد');
      expect(updated.status, 'active');
      expect(updated.confirmation, 'confirmed');
    });

    test('حذف حجز — حذف منطقي', () async {
      final id = await repo.addBooking(
        customerName: 'خالد',
        date: DateTime(2026, 10, 5),
        status: BookingStatus.confirmed,
      );
      await repo.deleteBooking(id);
      final deleted = await db.bookingsDao.getById(id);
      expect(deleted!.status, 'cancelled');
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
      );
      await repo.addBooking(
        customerName: 'عميل نوفمبر',
        date: DateTime(2026, 11, 5),
      );
      final octBookings = await repo.watchByMonth(2026, 10).first;
      expect(octBookings.length, 1);
      expect(octBookings.first.customerName, 'عميل أكتوبر');
    });

    test('watchByMonth يتحدث عند إضافة حجز جديد', () async {
      final first = await repo.watchByMonth(2026, 10).first;
      expect(first, isEmpty);
      await repo.addBooking(
        customerName: 'عميل جديد',
        date: DateTime(2026, 10, 8),
      );
      final second = await repo.watchByMonth(2026, 10).first;
      expect(second.length, 1);
    });

    test('watchByDate يُرجع حجوزات اليوم المحدد فقط', () async {
      await repo.addBooking(
        customerName: 'عميل يوم 10',
        date: DateTime(2026, 10, 10, 9),
      );
      await repo.addBooking(
        customerName: 'عميل يوم 11',
        date: DateTime(2026, 10, 11, 9),
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
      );
      final row = await db.bookingsDao.getById(id);
      expect(row!.eventDate, '2026-12-31');
    });
  });
}
