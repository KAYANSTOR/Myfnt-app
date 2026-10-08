import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/company/company_providers.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';
import '../data/message_number_repository.dart';

final messageNumberRepositoryProvider = Provider<MessageNumberRepository>((ref) => MessageNumberRepository(db: ref.watch(appDatabaseProvider), companyId: ref.watch(currentCompanyIdProvider), actorId: ref.watch(currentUserIdProvider), actorName: 'المستخدم المحلي'));
final allMessageNumbersProvider = StreamProvider<List<CompanyMessageNumberRow>>((ref) => ref.watch(messageNumberRepositoryProvider).watchAll());
