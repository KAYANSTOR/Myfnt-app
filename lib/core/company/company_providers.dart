// lib/core/company/company_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'company_service.dart';

final currentCompanyIdProvider = Provider<String>((ref) => kLocalCompanyId);

final currentUserIdProvider = Provider<String>((ref) => kLocalUserId);

final companyServiceProvider = Provider<CompanyService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CompanyService(db);
});

final companyBootstrapProvider = FutureProvider<CompanyRow>((ref) async {
  final service = ref.watch(companyServiceProvider);
  return service.ensureLocalCompany();
});
