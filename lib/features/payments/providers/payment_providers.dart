// lib/features/payments/providers/payment_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/company/company_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(currentCompanyIdProvider);
  final userId = ref.watch(currentUserIdProvider);
  return PaymentRepository(
    db: db,
    companyId: companyId,
    actorId: userId,
    actorName: 'المستخدم المحلي',
  );
});

final bookingPaymentsProvider =
    StreamProvider.family<List<PaymentRow>, String>((ref, bookingId) {
  return ref.watch(paymentRepositoryProvider).watchByBooking(bookingId);
});
