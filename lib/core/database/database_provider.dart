import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Provider لقاعدة البيانات — instance واحد طوال عمر التطبيق
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provider لـ DAO الحجوزات
final bookingsDaoProvider = Provider<BookingsDao>((ref) {
  return ref.watch(appDatabaseProvider).bookingsDao;
});

/// Provider لـ DAO العملاء
final customersDaoProvider = Provider<CustomersDao>((ref) {
  return ref.watch(appDatabaseProvider).customersDao;
});
