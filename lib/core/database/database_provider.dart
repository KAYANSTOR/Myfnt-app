// lib/core/database/database_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'daos/bookings_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/payments_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final bookingsDaoProvider = Provider<BookingsDao>((ref) {
  return ref.watch(appDatabaseProvider).bookingsDao;
});

final customersDaoProvider = Provider<CustomersDao>((ref) {
  return ref.watch(appDatabaseProvider).customersDao;
});

final paymentsDaoProvider = Provider<PaymentsDao>((ref) {
  return ref.watch(appDatabaseProvider).paymentsDao;
});

final outboxDaoProvider = Provider<OutboxDao>((ref) {
  return ref.watch(appDatabaseProvider).outboxDao;
});
