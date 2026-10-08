// lib/features/customers/providers/customer_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/company/company_providers.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/tables.dart';
import '../data/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(currentCompanyIdProvider);
  return CustomerRepository(db: db, companyId: companyId);
});

final allCustomersProvider = StreamProvider<List<CustomerRow>>((ref) {
  return ref.watch(customerRepositoryProvider).watchAll();
});
