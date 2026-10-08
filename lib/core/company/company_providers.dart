// lib/core/company/company_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import '../database/tables.dart';
import 'company_service.dart';

/// Provider لمعرّف الشركة الحالية (ثابت في هذه المرحلة).
final currentCompanyIdProvider = Provider<String>((ref) => kLocalCompanyId);

/// Provider لمعرّف المستخدم الحالي.
final currentUserIdProvider = Provider<String>((ref) => kLocalUserId);

/// Provider لخدمة الشركة.
final companyServiceProvider = Provider<CompanyService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CompanyService(db);
});

/// Provider غير متزامن: يُنشئ الشركة إن لم توجد ويعيدها.
/// يُستخدَم في bootstrap عند بدء التطبيق.
final companyBootstrapProvider = FutureProvider<CompanyRow>((ref) async {
  final service = ref.watch(companyServiceProvider);
  return service.ensureLocalCompany();
});
