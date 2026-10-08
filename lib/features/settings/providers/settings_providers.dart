import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/company/company_providers.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/tables.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository(db: ref.watch(appDatabaseProvider), companyId: ref.watch(currentCompanyIdProvider)));
final companySettingsProvider = StreamProvider<CompanySettingsRow?>((ref) => ref.watch(settingsRepositoryProvider).watch());
