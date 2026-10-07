import 'package:drift/drift.dart';

/// جدول الحجوزات
class BookingsTable extends Table {
  @override
  String get tableName => 'bookings';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerName => text().withLength(min: 1, max: 200)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text().withDefault(const Constant('confirmed'))();
  TextColumn get note => text().nullable()();
  RealColumn get amountTotal => real().withDefault(const Constant(0.0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// جدول العملاء — هيكل أساسي جاهز للتوسع
class CustomersTable extends Table {
  @override
  String get tableName => 'customers';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
