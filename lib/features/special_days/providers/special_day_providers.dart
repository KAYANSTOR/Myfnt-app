import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/company/company_providers.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/tables.dart';
import '../data/special_day_repository.dart';

final specialDayRepositoryProvider = Provider<SpecialDayRepository>((ref) => SpecialDayRepository(db: ref.watch(appDatabaseProvider), companyId: ref.watch(currentCompanyIdProvider), actorId: ref.watch(currentUserIdProvider), actorName: 'المستخدم المحلي'));
final allSpecialDaysProvider = StreamProvider<List<CalendarBlockRow>>((ref) => ref.watch(specialDayRepositoryProvider).watchAll());
